# frozen_string_literal: true

require "test_helper"

class TestCLIInstall < Minitest::Test
  include CLIHelpers

  def setup
    @dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def test_install_defaults_to_current_directory_and_both_targets
    code, out, = Dir.chdir(@dir) { run_cli("install", "--dry-run") }
    assert_equal 0, code
    assert_includes out, "would write .codex/agents/rails_explorer.toml"
    assert_includes out, "would write .claude/agents/rails_explorer.md"
    assert_empty Dir.children(@dir)
  end

  def test_codex_flag_limits_writes_to_codex_files
    _, out, = run_cli("install", @dir, "--codex", "--dry-run")
    assert_includes out, ".codex/agents/"
    refute_includes out, ".claude/agents/"
  end

  def test_claude_flag_limits_writes_to_claude_files
    _, out, = run_cli("install", @dir, "--claude", "--dry-run")
    assert_includes out, ".claude/agents/"
    refute_includes out, ".codex/agents/"
  end

  def test_install_fills_model_routing_in_both_instruction_files
    run_cli("install", @dir)
    content = File.read(File.join(@dir, "AGENTS.md"))
    refute_includes content, "{{model_routing}}"
    assert_includes content, "Model assignments are starting points. Model tiers: `fast` for quick read-only " \
                             "lookups (Codex gpt-6-luna low, Claude sonnet low): `rails_explorer`. "
    assert_equal content, File.read(File.join(@dir, "CLAUDE.md"))
  end

  def test_repeat_install_only_skips
    run_cli("install", @dir)
    _, out, = run_cli("install", @dir)
    assert out.lines.all? { |line| line.start_with?("skip ") }, out
  end

  def test_force_flag_overwrites_edited_agent_file
    run_cli("install", @dir, "--codex")
    File.write(codex_explorer_path, "# my notes\n", mode: "a")
    _, out, = run_cli("install", @dir, "--codex", "--force")
    assert_includes out, "overwrite .codex/agents/rails_explorer.toml\n"
    refute_includes File.read(codex_explorer_path), "# my notes"
  end

  def test_status_exits_one_before_install
    code, out, = run_cli("status", @dir)
    assert_equal 1, code
    assert_includes out, "missing block AGENTS.md"
  end

  def test_status_exits_zero_after_install
    run_cli("install", @dir)
    code, out, = run_cli("status", @dir)
    assert_equal 0, code
    assert_equal 28, out.lines.length
    assert out.lines.all? { |line| line.start_with?("up to date ") }, out
  end

  def test_status_reports_edited_agent_and_exits_one
    run_cli("install", @dir, "--codex")
    File.write(codex_explorer_path, "# my notes\n", mode: "a")
    code, out, = run_cli("status", @dir, "--codex")
    assert_equal 1, code
    assert_includes out, "edited        .codex/agents/rails_explorer.toml\n"
    refute_includes out, ".claude/"
  end

  def test_advisor_flag_runs_plugin_commands_after_the_install
    calls = []
    runner = ->(argv, dir) { calls << [argv, dir] && ["done", true] }
    code, out, = run_cli("install", @dir, "--claude", "--advisor", plugin_runner: runner)
    assert_equal 0, code
    assert_includes out, "write .claude/agents/advisor.md"
    assert_equal [%w[claude plugin marketplace add lucianghinda/my-ruby-coding-agents],
                  %w[claude plugin install advisor@my-ruby-coding-agents --scope project]], calls.map(&:first)
    assert_equal([File.realpath(@dir)] * 2, calls.map { |_, dir| File.realpath(dir) })
  end

  def test_advisor_source_overrides_the_marketplace_source_and_dry_run_only_prints
    calls = []
    runner = ->(argv, _dir) { calls << argv }
    code, out, = run_cli("install", @dir, "--codex", "--advisor", "--advisor-source", "/tmp/co", "--dry-run",
                         plugin_runner: runner)
    assert_equal 0, code
    assert_includes out, "would run codex plugin marketplace add /tmp/co"
    assert_empty calls
  end

  def test_advisor_flag_exits_one_when_a_plugin_command_fails
    code, out, = run_cli("install", @dir, "--advisor", plugin_runner: ->(_argv, _dir) { ["no network", false] })
    assert_equal 1, code
    assert_includes out, "failed: codex plugin marketplace add"
  end

  def test_install_without_advisor_flag_runs_no_plugin_commands
    code, = run_cli("install", @dir, plugin_runner: ->(_argv, _dir) { flunk "must not run" })
    assert_equal 0, code
  end

  private

  def codex_explorer_path = File.join(@dir, ".codex/agents/rails_explorer.toml")
end
