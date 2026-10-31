# frozen_string_literal: true

require "test_helper"
require "json"

# Checks the files the advisor plugin ships and the marketplaces that point at it.
class TestAdvisorPluginFiles < Minitest::Test
  PLUGIN = File.expand_path("../../plugins/advisor", __dir__)
  SCRIPT = File.join(PLUGIN, "scripts/advisor_hook.rb")
  REPO = File.expand_path("../..", __dir__)

  def test_plugin_agent_files_match_the_template
    models = MyRubyCodingAgents::Templates.models
    agent = MyRubyCodingAgents::Agent.load(File.join(MyRubyCodingAgents::Templates::AGENTS_DIR, "advisor.md"), models:)
    assert_equal MyRubyCodingAgents::Renderers.claude(agent), File.read(File.join(PLUGIN, "agents/advisor.md"))
    assert_equal MyRubyCodingAgents::Renderers.codex(agent), File.read(File.join(PLUGIN, "agents/advisor.toml"))
  end

  def test_both_manifests_name_the_plugin
    assert_equal "advisor", read_json(PLUGIN, "plugin.json")["name"]
    assert_equal "advisor", read_json(PLUGIN, ".claude-plugin/plugin.json")["name"]
  end

  def test_every_hook_runs_the_plugin_script
    hooks = read_json(PLUGIN, "hooks/hooks.json")["hooks"]
    assert_equal %w[PostToolUse SessionStart Stop SubagentStop], hooks.keys.sort
    commands = hooks.values.flatten.flat_map { |group| group["hooks"] }.map { |hook| hook["command"] }
    commands.each { |command| assert_includes command, "${CLAUDE_PLUGIN_ROOT}/scripts/advisor_hook.rb" }
  end

  def test_marketplaces_point_at_the_plugin
    assert_equal "./plugins/advisor", read_json(REPO, ".claude-plugin/marketplace.json")["plugins"][0]["source"]
    assert_equal "./plugins/advisor",
                 read_json(REPO, ".agents/plugins/marketplace.json")["plugins"][0]["source"]["path"]
  end

  private

  def read_json(*parts)
    JSON.parse(File.read(File.join(*parts)))
  end
end
