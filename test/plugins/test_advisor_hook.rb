# frozen_string_literal: true

require "test_helper"
require "json"
require "open3"
require "tmpdir"

# Drives the advisor hook script through one session.
# rubocop:disable Metrics/ClassLength
class TestAdvisorHook < Minitest::Test
  SCRIPT = File.expand_path("../../plugins/advisor/scripts/advisor_hook.rb", __dir__)

  def test_hooks_stay_quiet_when_the_mode_is_off
    Dir.mktmpdir do |dir|
      assert_equal "", hook(dir, "session_start")
      hook(dir, "post_tool_use")
      assert_equal "", hook(dir, "stop", "last_assistant_message" => "done")
      refute File.exist?(File.join(dir, ".advisor"))
    end
  end

  def test_enable_writes_state_and_excludes_the_folder_from_git
    Dir.mktmpdir do |dir|
      git(dir, "init", "-q")
      assert_includes command(dir, "enable"), "Advisor mode on"
      exclude = git(dir, "rev-parse", "--git-path", "info/exclude").strip
      assert_includes File.read(File.expand_path(exclude, dir)), ".advisor/"
      assert_includes hook(dir, "session_start"), "Advisor mode is on"
      command(dir, "disable")
      refute File.exist?(File.join(dir, ".advisor"))
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def test_enable_excludes_advisor_state_in_a_git_worktree
    skip "git is unavailable" unless system("git", "--version", out: File::NULL, err: File::NULL)

    Dir.mktmpdir do |dir|
      repo = File.join(dir, "repo")
      worktree = File.join(dir, "worktree")
      Dir.mkdir(repo)
      git(repo, "init", "-q")
      git(repo, "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "--allow-empty", "-qm",
          "initial")
      git(repo, "worktree", "add", "-q", "-b", "advisor-test", worktree)

      command(worktree, "enable")

      exclude = git(worktree, "rev-parse", "--git-path", "info/exclude").strip
      exclude = File.expand_path(exclude, worktree)
      assert_includes File.read(exclude), ".advisor/"
      assert_equal "", git(worktree, "status", "--short").strip
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def test_enable_preserves_exclude_content_without_a_trailing_newline
    Dir.mktmpdir do |dir|
      git(dir, "init", "-q")
      exclude = git(dir, "rev-parse", "--git-path", "info/exclude").strip
      exclude = File.expand_path(exclude, dir)
      File.write(exclude, "existing-pattern")

      command(dir, "enable")

      assert_equal "existing-pattern\n.advisor/\n", File.read(exclude)
    end
  end

  def test_enable_does_not_crash_when_git_is_unavailable_or_directory_is_not_a_repo
    Dir.mktmpdir do |dir|
      out, status = Open3.capture2({ "PATH" => "" }, RbConfig.ruby, SCRIPT, "enable", chdir: dir)
      assert status.success?, out
      assert File.file?(File.join(dir, ".advisor/state.json"))
    end
  end

  def test_status_recovers_from_valid_json_with_the_wrong_shape
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, ".advisor"))
      File.write(File.join(dir, ".advisor/state.json"), "[]")

      status = command(dir, "status")

      assert_includes status, "enabled: false"
      assert_includes status, "consults: 0"
    end
  end

  def test_consult_recovers_from_an_invalid_counter_in_state
    enabled_with_pending_edit do |dir|
      path = File.join(dir, ".advisor/state.json")
      state = JSON.parse(File.read(path)).merge("consults" => [])
      File.write(path, JSON.generate(state))

      hook(dir, "subagent_stop", "agent_type" => "advisor", "agent_id" => "a1")

      assert_includes command(dir, "status"), "consults: 1"
      refute pending?(dir)
    end
  end

  def test_stop_nudges_once_per_batch_of_edits
    enabled_with_pending_edit do |dir|
      nudge = JSON.parse(hook(dir, "stop", "last_assistant_message" => "Done."))
      assert_equal "block", nudge["decision"]
      assert_includes nudge["reason"], "[Advisor]"
      refute pending?(dir)
      assert_equal "", hook(dir, "stop", "last_assistant_message" => "Done.")
    end
  end

  def test_consult_is_counted_logged_and_clears_pending_edits
    enabled_with_pending_edit do |dir|
      hook(dir, "subagent_stop", "agent_type" => "advisor", "agent_id" => "a1",
                                 "last_assistant_message" => "Verdict: go.")
      refute pending?(dir)
      status = command(dir, "status")
      assert_includes status, "consults: 1"
      assert_includes status, "advisor_agent_id: a1"
      assert_includes File.read(File.join(dir, ".advisor/log.md")), "Verdict: go."
    end
  end

  def test_substring_match_on_non_advisor_agent_does_not_count_as_consult
    enabled_with_pending_edit do |dir|
      hook(dir, "subagent_stop", "agent_type" => "rails-advisor-reviewer", "agent_id" => "a1",
                                 "last_assistant_message" => "Not the advisor.")
      assert pending?(dir)
      assert_includes command(dir, "status"), "consults: 0"
    end
  end

  def test_namespaced_advisor_agent_counts_as_consult
    enabled_with_pending_edit do |dir|
      hook(dir, "subagent_stop", "agent_type" => "plugin:advisor", "agent_id" => "a1",
                                 "last_assistant_message" => "Verdict: go.")
      refute pending?(dir)
      assert_includes command(dir, "status"), "consults: 1"
    end
  end

  def test_shell_tool_use_marks_pending
    Dir.mktmpdir do |dir|
      command(dir, "enable")
      hook(dir, "post_tool_use", "tool_name" => "Bash")
      assert pending?(dir)
    end
  end

  def test_stop_keeps_edits_pending_after_a_question
    enabled_with_pending_edit do |dir|
      assert_equal "", hook(dir, "stop", "last_assistant_message" => "Which option do you prefer?")
      assert pending?(dir)
    end
  end

  def test_stop_does_not_nudge_twice_in_one_turn
    enabled_with_pending_edit do |dir|
      assert_equal "", hook(dir, "stop", "stop_hook_active" => true, "last_assistant_message" => "Done.")
    end
  end

  def test_stop_accepts_an_advisor_line_as_handled
    enabled_with_pending_edit do |dir|
      assert_equal "", hook(dir, "stop", "last_assistant_message" => "Advisor: not needed, one-line typo fix.")
      refute pending?(dir)
    end
  end

  def test_nudge_off_silences_stop
    enabled_with_pending_edit do |dir|
      command(dir, "nudge", "off")
      assert_equal "", hook(dir, "stop", "last_assistant_message" => "Done.")
    end
  end

  private

  def enabled_with_pending_edit
    Dir.mktmpdir do |dir|
      command(dir, "enable")
      hook(dir, "post_tool_use")
      assert pending?(dir)
      yield dir
    end
  end

  def pending?(dir)
    File.file?(File.join(dir, ".advisor/pending"))
  end

  def hook(dir, event, input = {})
    out, status = Open3.capture2(RbConfig.ruby, SCRIPT, event, stdin_data: JSON.generate(input.merge("cwd" => dir)))
    assert status.success?, out
    out
  end

  def command(dir, *args)
    out, status = Open3.capture2(RbConfig.ruby, SCRIPT, *args, chdir: dir)
    assert status.success?, out
    out
  end

  def git(dir, *args)
    out, status = Open3.capture2("git", "-C", dir, *args)
    assert status.success?, out
    out
  end
end
# rubocop:enable Metrics/ClassLength
