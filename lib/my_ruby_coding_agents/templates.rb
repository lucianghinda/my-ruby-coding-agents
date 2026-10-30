# frozen_string_literal: true

module MyRubyCodingAgents
  # Loads the bundled templates: the model tier table, the agents, and the
  # delegation instructions.
  module Templates
    ROOT = File.expand_path("../../templates", __dir__)
    AGENTS_DIR = File.join(ROOT, "agents")
    INSTRUCTIONS_PATH = File.join(ROOT, "instructions.md")
    MODELS_PATH = File.join(ROOT, "models.yml")
    ROUTING_PLACEHOLDER = "{{model_routing}}"

    module_function

    def models
      Models.load(MODELS_PATH)
    end

    # Agents sorted by file name, with models resolved from their tiers.
    def agents(models)
      Dir.glob(File.join(AGENTS_DIR, "*.md")).sort.map { |path| Agent.load(path, models:) }
    end

    # Instructions with the routing placeholder replaced by a sentence built
    # from the tier table and the agents' tiers.
    def instructions(models, agents)
      File.read(INSTRUCTIONS_PATH).gsub(ROUTING_PLACEHOLDER, models.routing(agents))
    end
  end
end
