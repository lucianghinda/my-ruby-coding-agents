# frozen_string_literal: true

# Shared template input for parser, renderer, and installer tests.
module AgentFixture
  MODELS_SOURCE = <<~YAML
    fast:
      summary: quick lookups
      codex:
        model: gpt-6-luna
        effort: low
      claude:
        model: sonnet
        effort: low
    strong:
      summary: security review
      codex:
        model: gpt-6.1-sol
        effort: high
      claude:
        model: opus
        effort: high
  YAML

  SOURCE = <<~MD
    ---
    name: sample_agent
    description: Reads Rails code.
    tier: fast
    tools: Read, Grep, Glob
    ---
    Read the app and explain the workflow.
  MD

  module_function

  def models
    MyRubyCodingAgents::Models.parse(MODELS_SOURCE)
  end

  def agent(source = SOURCE)
    MyRubyCodingAgents::Agent.parse(source, models:)
  end
end
