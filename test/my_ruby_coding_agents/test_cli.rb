# frozen_string_literal: true

require "test_helper"

class TestCLI < Minitest::Test
  include CLIHelpers

  def test_help_flag_prints_usage
    code, out, = run_cli("--help")
    assert_equal 0, code
    assert_includes out, "install [DIR]"
    assert_includes out, "status [DIR]"
  end

  def test_short_help_flag_prints_usage
    assert_equal [0, run_cli("--help")[1]], run_cli("-h").first(2)
  end

  def test_no_command_prints_usage
    assert_equal [0, run_cli("--help")[1]], run_cli.first(2)
  end

  def test_version_flags_print_version
    assert_equal [0, "#{MyRubyCodingAgents::VERSION}\n"], run_cli("--version").first(2)
    assert_equal [0, "#{MyRubyCodingAgents::VERSION}\n"], run_cli("-v").first(2)
  end

  def test_unknown_command_returns_usage_error
    code, _, err = run_cli("unknown")
    assert_equal 2, code
    assert_includes err, "Unknown command: unknown"
  end

  def test_list_shows_agent_tier_models_and_description
    code, out, = run_cli("list")
    assert_equal 0, code
    assert_includes out, "rails_explorer | fast | Codex: gpt-6-luna (low) | Claude: sonnet (low) | Trace "
    assert_includes out, "security_reviewer | strong | Codex: gpt-6.1-sol (high) | Claude: opus (high) | "
    assert_equal 13, out.lines.length
  end

  def test_install_help_lists_install_options_and_writes_nothing
    Dir.mktmpdir do |dir|
      code, out, = run_cli("install", dir, "--help")
      assert_equal 0, code
      assert_includes out, "Usage: my-ruby-coding-agents install [DIR] [options]"
      assert_includes out, "--force"
      assert_empty Dir.children(dir)
    end
  end

  def test_status_help_lists_target_options_without_install_options
    code, out, = run_cli("status", "--help")
    assert_equal 0, code
    assert_includes out, "Usage: my-ruby-coding-agents status [DIR] [options]"
    assert_includes out, "--claude"
    refute_includes out, "--force"
  end

  def test_status_rejects_install_only_flags
    code, _, err = run_cli("status", "--force")
    assert_equal 2, code
    assert_includes err, "--force"
  end

  def test_rejects_more_than_one_target_directory
    code, _, err = run_cli("install", "first", "second")
    assert_equal 2, code
    assert_includes err, "expected at most one target directory"
  end

  def test_file_system_errors_are_not_reported_as_usage_errors
    Dir.mktmpdir do |dir|
      file = File.join(dir, "not_a_directory")
      File.write(file, "")
      assert_raises(SystemCallError) { run_cli("install", file) }
    end
  end
end
