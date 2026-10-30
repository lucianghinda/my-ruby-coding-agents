# frozen_string_literal: true

require "test_helper"
require "my_ruby_coding_agents/templates"

class TestBundledTemplates < Minitest::Test
  def setup
    @models = MyRubyCodingAgents::Templates.models
    @paths = Dir.glob(File.join(MyRubyCodingAgents::Templates::AGENTS_DIR, "*.md")).sort
  end

  def test_every_bundled_agent_renders_for_both_tools
    assert_equal 10, @paths.length
    @paths.each do |path|
      agent = MyRubyCodingAgents::Agent.load(path, models: @models)
      assert_includes MyRubyCodingAgents::Renderers.codex(agent), "model = \"#{agent.codex_model}\""
      assert_includes MyRubyCodingAgents::Renderers.claude(agent), "model: #{agent.claude_model}"
    end
  end

  def test_every_bundled_tier_is_used
    used = @paths.map { |path| MyRubyCodingAgents::Agent.load(path, models: @models).tier.name }.uniq
    assert_equal @models.names.sort, used.sort
  end

  def test_instructions_template_has_routing_placeholder
    instructions = File.read(MyRubyCodingAgents::Templates::INSTRUCTIONS_PATH)
    assert_includes instructions, MyRubyCodingAgents::Templates::ROUTING_PLACEHOLDER
  end
end
