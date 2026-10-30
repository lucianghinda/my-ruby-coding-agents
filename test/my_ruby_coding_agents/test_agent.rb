# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "my_ruby_coding_agents/agent"

class TestAgent < Minitest::Test
  def test_parses_frontmatter_and_body
    agent = AgentFixture.agent
    assert_equal "sample_agent", agent.name
    assert_equal "fast", agent.tier.name
    assert_equal %w[Read Grep Glob], agent.tools
    assert_equal "Read the app and explain the workflow.", agent.body
  end

  def test_resolves_models_and_efforts_from_tier
    agent = AgentFixture.agent(AgentFixture::SOURCE.sub("tier: fast", "tier: strong"))
    assert_equal %w[gpt-6.1-sol high opus high],
                 [agent.codex_model, agent.codex_effort, agent.claude_model, agent.claude_effort]
  end

  def test_rejects_unknown_tier
    error = assert_raises(ArgumentError) do
      AgentFixture.agent(AgentFixture::SOURCE.sub("tier: fast", "tier: huge"))
    end
    assert_equal 'unknown model tier: "huge" (known tiers: fast, strong)', error.message
  end

  def test_rejects_missing_fields
    error = assert_raises(ArgumentError) { AgentFixture.agent("---\nname: x\n---\nbody") }
    assert_equal "missing agent fields: description, tier", error.message
  end

  def test_rejects_old_per_agent_model_fields
    source = AgentFixture::SOURCE.sub("tier: fast", "tier: fast\ncodex_model: gpt-6-luna")
    error = assert_raises(ArgumentError) { AgentFixture.agent(source) }
    assert_equal "unknown agent fields: codex_model", error.message
  end

  def test_rejects_template_without_frontmatter
    error = assert_raises(ArgumentError) { AgentFixture.agent("Read the app.\n") }
    assert_equal "agent template must begin with YAML frontmatter", error.message
  end

  def test_rejects_frontmatter_that_is_not_a_mapping
    error = assert_raises(ArgumentError) { AgentFixture.agent("---\n- name\n---\nbody") }
    assert_equal "agent frontmatter must be a mapping", error.message
  end

  def test_rejects_invalid_frontmatter_yaml
    error = assert_raises(ArgumentError) { AgentFixture.agent("---\nname: [\n---\nbody") }
    assert_match(/\Ainvalid agent frontmatter:/, error.message)
  end

  def test_load_prefixes_errors_with_file_name
    Dir.mktmpdir do |dir|
      path = File.join(dir, "broken_agent.md")
      File.write(path, "Read the app.\n")
      error = assert_raises(ArgumentError) { MyRubyCodingAgents::Agent.load(path, models: AgentFixture.models) }
      assert_equal "broken_agent.md: agent template must begin with YAML frontmatter", error.message
    end
  end
end
