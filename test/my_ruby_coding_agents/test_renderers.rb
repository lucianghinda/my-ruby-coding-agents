# frozen_string_literal: true

require "test_helper"
require "my_ruby_coding_agents/agent"
require "my_ruby_coding_agents/renderers"

class TestRenderers < Minitest::Test
  def setup
    @agent = AgentFixture.agent
  end

  def test_renders_codex_toml
    assert_equal <<~TOML, MyRubyCodingAgents::Renderers.codex(@agent)
      # my-ruby-coding-agents: 318cb542d4351ded
      name = "sample_agent"
      description = "Reads Rails code."
      model = "gpt-6-luna"
      model_reasoning_effort = "low"
      developer_instructions = """
      Read the app and explain the workflow.
      """
    TOML
  end

  CLAUDE_MARKDOWN = <<~MD
    ---
    name: sample_agent
    description: "Reads Rails code."
    model: sonnet
    effort: low
    tools: Read, Grep, Glob
    ---
    <!-- my-ruby-coding-agents: 5ee4bbfacb3eb34f -->

    Read the app and explain the workflow.
  MD

  def test_renders_claude_markdown
    assert_equal CLAUDE_MARKDOWN, MyRubyCodingAgents::Renderers.claude(@agent)
  end

  def test_claude_markdown_omits_tools_line_when_agent_has_no_tools
    agent = AgentFixture.agent(AgentFixture::SOURCE.sub("tools: Read, Grep, Glob\n", ""))
    refute_includes MyRubyCodingAgents::Renderers.claude(agent), "tools:"
  end

  def test_claude_markdown_omits_tools_line_when_tools_field_is_blank
    agent = AgentFixture.agent(AgentFixture::SOURCE.sub("tools: Read, Grep, Glob", 'tools: ""'))
    refute_includes MyRubyCodingAgents::Renderers.claude(agent), "tools:"
  end
end
