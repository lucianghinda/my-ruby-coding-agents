# frozen_string_literal: true

require "test_helper"

class TestStatus < Minitest::Test
  include InstallerHelpers

  def test_reports_missing_files
    clean, lines = status
    refute clean
    assert_equal ["missing       #{CODEX_PATH}", "missing block AGENTS.md",
                  "missing       #{CLAUDE_PATH}", "missing block CLAUDE.md"], lines
  end

  def test_reports_up_to_date_after_install
    install
    clean, lines = status
    assert clean
    assert(lines.all? { |line| line.start_with?("up to date ") }, lines.inspect)
  end

  def test_reports_outdated_and_edited_files
    install(agent: old_agent)
    File.write(path(CLAUDE_PATH), "edited")
    @instructions = "New guide."
    clean, lines = status
    refute clean
    assert_equal ["outdated      #{CODEX_PATH}", "outdated      AGENTS.md",
                  "edited        #{CLAUDE_PATH}", "outdated      CLAUDE.md"], lines
  end

  def test_treats_import_as_clean
    install(targets: [:codex])
    File.write(path("CLAUDE.md"), "@AGENTS.md\n")
    install(targets: [:claude])
    clean, lines = status
    assert clean, lines.inspect
    assert_includes lines, "skipped       CLAUDE.md (imports AGENTS.md)"
  end
end
