# frozen_string_literal: true

require "test_helper"
require "my_ruby_coding_agents/models"

class TestModels < Minitest::Test
  def test_fetches_tier_settings
    tier = AgentFixture.models.fetch("strong")
    assert_equal "security review", tier.summary
    assert_equal %w[gpt-6.1-sol high opus high],
                 [tier.codex_model, tier.codex_effort, tier.claude_model, tier.claude_effort]
  end

  def test_names_keep_file_order
    assert_equal %w[fast strong], AgentFixture.models.names
  end

  def test_unknown_tier_lists_known_tiers
    error = assert_raises(ArgumentError) { AgentFixture.models.fetch("huge") }
    assert_equal 'unknown model tier: "huge" (known tiers: fast, strong)', error.message
  end

  def test_rejects_empty_table
    error = assert_raises(ArgumentError) { MyRubyCodingAgents::Models.parse("") }
    assert_equal "models.yml must map tier names to settings", error.message
  end

  def test_rejects_empty_mapping
    error = assert_raises(ArgumentError) { MyRubyCodingAgents::Models.parse("{}") }
    assert_equal "models.yml must map tier names to settings", error.message
  end

  def test_rejects_tier_that_is_not_a_mapping
    error = assert_raises(ArgumentError) { MyRubyCodingAgents::Models.parse("fast: quick lookups\n") }
    assert_equal "tier fast must be a mapping", error.message
  end

  def test_rejects_invalid_yaml
    error = assert_raises(ArgumentError) { MyRubyCodingAgents::Models.parse("fast: [") }
    assert_match(/\Ainvalid models.yml:/, error.message)
  end

  def test_rejects_unknown_tier_key
    error = assert_raises(ArgumentError) { parse_with("  summary: quick lookups", "  summary: x\n  extra: y") }
    assert_equal "unknown keys in tier fast: extra", error.message
  end

  def test_rejects_missing_tool
    source = AgentFixture::MODELS_SOURCE.split("strong:").first.sub(/  claude:\n.*\z/m, "")
    error = assert_raises(ArgumentError) { MyRubyCodingAgents::Models.parse(source) }
    assert_equal "missing keys in tier fast: claude", error.message
  end

  def test_rejects_unknown_tool_key
    error = assert_raises(ArgumentError) do
      parse_with("    effort: low\n  claude:", "    effort: low\n    temp: 1\n  claude:")
    end
    assert_equal "unknown keys in tier fast codex: temp", error.message
  end

  def test_rejects_missing_effort
    error = assert_raises(ArgumentError) { parse_with("    model: opus\n    effort: high\n", "    model: opus\n") }
    assert_equal "missing keys in tier strong claude: effort", error.message
  end

  def test_rejects_blank_model
    error = assert_raises(ArgumentError) { parse_with("model: gpt-6-luna", 'model: " "') }
    assert_equal "tier fast codex model must be a non-empty string", error.message
  end

  def test_rejects_non_string_effort
    error = assert_raises(ArgumentError) { parse_with("effort: low", "effort: 3") }
    assert_equal "tier fast codex effort must be a non-empty string", error.message
  end

  def test_routing_lists_used_tiers_in_order_and_agents_by_name
    models = AgentFixture.models
    agents = [agent("zeta", "fast"), agent("alpha", "fast"), agent("guard", "strong")]
    assert_equal "Model tiers: `fast` for quick lookups (Codex gpt-6-luna low, Claude sonnet low): " \
                 "`alpha`, `zeta`. `strong` for security review (Codex gpt-6.1-sol high, Claude opus high): `guard`.",
                 models.routing(agents.reverse)
  end

  def test_routing_skips_unused_tiers
    assert_equal "Model tiers: `strong` for security review (Codex gpt-6.1-sol high, Claude opus high): `guard`.",
                 AgentFixture.models.routing([agent("guard", "strong")])
  end

  private

  def parse_with(from, to)
    MyRubyCodingAgents::Models.parse(AgentFixture::MODELS_SOURCE.sub(from, to))
  end

  def agent(name, tier)
    AgentFixture.agent(AgentFixture::SOURCE.sub("sample_agent", name).sub("tier: fast", "tier: #{tier}"))
  end
end
