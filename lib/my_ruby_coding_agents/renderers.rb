# frozen_string_literal: true

module MyRubyCodingAgents
  # Convert canonical agent definitions to tool-specific file formats.
  # Each file carries a Generated marker.
  module Renderers
    module_function

    def codex(agent)
      Generated.stamp(<<~TOML, style: :toml)
        name = #{toml(agent.name)}
        description = #{toml(agent.description)}
        model = #{toml(agent.codex_model)}
        model_reasoning_effort = #{toml(agent.codex_effort)}
        developer_instructions = """
        #{agent.body.lines(chomp: true).join("\n")}
        """
      TOML
    end

    def claude(agent)
      Generated.stamp("---\n#{claude_metadata(agent).join("\n")}\n---\n\n#{agent.body}\n", style: :markdown)
    end

    def claude_metadata(agent)
      metadata = ["name: #{yaml(agent.name)}", "description: #{yaml(agent.description)}",
                  "model: #{yaml(agent.claude_model)}", "effort: #{yaml(agent.claude_effort)}"]
      metadata << "tools: #{agent.tools.join(", ")}" if agent.tools && !agent.tools.empty?
      metadata
    end
    private_class_method :claude_metadata

    def toml(value)
      "\"#{value.to_s.gsub("\\", "\\\\").gsub('"', '\\"').gsub("\n", '\\n')}\""
    end
    private_class_method :toml

    def yaml(value)
      value.to_s.match?(/\A[A-Za-z0-9_.-]+\z/) ? value.to_s : value.to_s.inspect
    end
    private_class_method :yaml
  end
end
