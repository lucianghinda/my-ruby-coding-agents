# frozen_string_literal: true

require "test_helper"

class TestInstructionTargets < Minitest::Test
  include InstallerHelpers

  def link_claude_md_to_agents_md
    File.write(path("AGENTS.md"), "Project instructions\n")
    File.symlink(path("AGENTS.md"), path("CLAUDE.md"))
  end

  def test_writes_shared_instruction_file_once_when_claude_is_symlinked
    link_claude_md_to_agents_md

    assert_equal ["write AGENTS.md"], install.grep(/\.md\z/).grep_v(%r{/agents/})
    content = File.read(path("CLAUDE.md"))
    assert_equal 1, content.scan(MyRubyCodingAgents::Installer::START_MARKER).length
    assert File.symlink?(path("CLAUDE.md"))
  end

  def test_skips_claude_md_that_imports_agents_md_when_both_targets_run
    File.write(path("CLAUDE.md"), "# Claude\n\n  @AGENTS.md  \n")
    lines = install
    assert_includes lines, "write AGENTS.md"
    assert_includes lines, "skip CLAUDE.md (imports AGENTS.md)"
    assert_equal "# Claude\n\n  @AGENTS.md  \n", File.read(path("CLAUDE.md"))
  end

  def test_writes_agents_md_when_only_claude_runs_and_claude_md_imports_it
    File.write(path("CLAUDE.md"), "@AGENTS.md\n")
    assert_includes install(targets: [:claude]), "write AGENTS.md (imported by CLAUDE.md)"
    assert_includes File.read(path("AGENTS.md")), "Delegate clearly."
    assert_equal "@AGENTS.md\n", File.read(path("CLAUDE.md"))
    refute File.exist?(path(".codex"))
  end

  def test_mention_of_agents_md_inside_a_line_is_not_an_import
    File.write(path("CLAUDE.md"), "See @AGENTS.md for more.\n")
    assert_includes install(targets: [:claude]), "write CLAUDE.md"
  end
end
