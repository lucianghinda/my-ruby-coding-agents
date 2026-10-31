# frozen_string_literal: true

require "test_helper"
require "json"
require "open3"
require "tmpdir"

# Drives the advisor hook script through one session.
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
      Dir.mkdir(File.join(dir, ".git"))
      assert_includes command(dir, "enable"), "Advisor mode on"
      assert_equal ".advisor/\n", File.read(File.join(dir, ".git/info/exclude"))
      assert_includes hook(dir, "session_start"), "Advisor mode is on"
      command(dir, "disable")
      refute File.exist?(File.join(dir, ".advisor"))
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
end
