# frozen_string_literal: true

require "test_helper"

class TestInstaller < Minitest::Test
  include InstallerHelpers

  def test_writes_both_targets_and_marker_blocks
    assert_equal ["write #{CODEX_PATH}", "write AGENTS.md", "write #{CLAUDE_PATH}", "write CLAUDE.md"], install
    assert_equal MyRubyCodingAgents::Renderers.codex(@agent), File.read(path(CODEX_PATH))
    assert_equal MyRubyCodingAgents::Renderers.claude(@agent), File.read(path(CLAUDE_PATH))
    assert_includes File.read(path("AGENTS.md")),
                    "#{MyRubyCodingAgents::Installer::START_MARKER}\n## Delegating Rails work"
  end

  def test_repeat_install_skips_up_to_date_files
    install
    assert_equal ["skip #{CODEX_PATH} (up to date)", "skip AGENTS.md (up to date)",
                  "skip #{CLAUDE_PATH} (up to date)", "skip CLAUDE.md (up to date)"], install
  end

  def test_updates_unedited_generated_file_when_template_changes
    install(targets: [:codex], agent: old_agent)
    assert_equal ["update #{CODEX_PATH}", "skip AGENTS.md (up to date)"], install(targets: [:codex])
    assert_equal MyRubyCodingAgents::Renderers.codex(@agent), File.read(path(CODEX_PATH))
  end

  def test_skips_edited_generated_file_and_force_overwrites_it
    install(targets: [:claude])
    File.write(path(CLAUDE_PATH), File.read(path(CLAUDE_PATH)).sub("Read the app", "Read my app"))
    assert_includes install(targets: [:claude]), "skip #{CLAUDE_PATH} (edited; use --force to overwrite)"
    assert_includes File.read(path(CLAUDE_PATH)), "Read my app"

    assert_includes install(targets: [:claude], force: true), "overwrite #{CLAUDE_PATH}"
    assert_equal MyRubyCodingAgents::Renderers.claude(@agent), File.read(path(CLAUDE_PATH))
  end

  def test_skips_file_without_marker_and_force_overwrites_it
    FileUtils.mkdir_p(File.dirname(path(CODEX_PATH)))
    File.write(path(CODEX_PATH), "existing")
    assert_includes install(targets: [:codex]), "skip #{CODEX_PATH} (edited; use --force to overwrite)"
    assert_equal "existing", File.read(path(CODEX_PATH))

    install(targets: [:codex], force: true)
    assert_equal MyRubyCodingAgents::Renderers.codex(@agent), File.read(path(CODEX_PATH))
  end

  def test_dry_run_reports_would_verbs_without_writing
    assert_equal ["would write #{CODEX_PATH}", "would write AGENTS.md"], install(targets: [:codex], dry_run: true)
    refute File.exist?(path(".codex"))
  end

  def test_dry_run_reports_would_update_and_would_overwrite
    install(agent: old_agent)
    File.write(path(CLAUDE_PATH), "edited")
    lines = install(dry_run: true, force: true)
    assert_includes lines, "would update #{CODEX_PATH}"
    assert_includes lines, "would overwrite #{CLAUDE_PATH}"
    assert_equal "edited", File.read(path(CLAUDE_PATH))
  end

  def test_replaces_existing_marker_block
    File.write(path("AGENTS.md"), "intro\n\n#{MyRubyCodingAgents::Installer::START_MARKER}\nold\n" \
                                  "#{MyRubyCodingAgents::Installer::END_MARKER}\n\noutro\n")
    assert_includes install(targets: [:codex]), "update AGENTS.md"
    result = File.read(path("AGENTS.md"))
    assert_includes result, "intro"
    assert_includes result, "outro"
    assert_includes result, "Delegate clearly."
    refute_includes result, "old"
  end
end
