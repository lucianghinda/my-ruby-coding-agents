# frozen_string_literal: true

require "yaml"

module MyRubyCodingAgents
  # Model tier table loaded from models.yml. Maps a tier name to the model
  # and reasoning effort each tool uses.
  class Models
    TIER_KEYS = %w[summary codex claude].freeze
    TOOL_KEYS = %w[model effort].freeze

    # One resolved tier.
    Tier = Data.define(:name, :summary, :codex_model, :codex_effort, :claude_model, :claude_effort)

    def self.load(path)
      parse(File.read(path))
    end

    def self.parse(source)
      new(YAML.safe_load(source, permitted_classes: [], aliases: false))
    rescue Psych::Exception => e
      raise ArgumentError, "invalid models.yml: #{e.message}"
    end

    def initialize(table)
      raise ArgumentError, "models.yml must map tier names to settings" unless table.is_a?(Hash) && !table.empty?

      @tiers = table.to_h { |name, settings| [name.to_s, build_tier(name.to_s, settings)] }.freeze
      freeze
    end

    # Tier names in file order.
    def names
      @tiers.keys
    end

    def fetch(name)
      @tiers.fetch(name.to_s) do
        raise ArgumentError, "unknown model tier: #{name.inspect} (known tiers: #{names.join(", ")})"
      end
    end

    # One sentence per used tier: its purpose, models, and agents.
    # Tiers keep file order and agents are sorted by name, so output is stable.
    def routing(agents)
      groups = agents.group_by { |agent| agent.tier.name }
      parts = names.filter_map do |name|
        next unless groups.key?(name)

        "#{describe(fetch(name))}: #{groups[name].map { |agent| "`#{agent.name}`" }.sort.join(", ")}."
      end
      "Model tiers: #{parts.join(" ")}"
    end

    private

    def describe(tier)
      "`#{tier.name}` for #{tier.summary} (Codex #{tier.codex_model} #{tier.codex_effort}, " \
        "Claude #{tier.claude_model} #{tier.claude_effort})"
    end

    def build_tier(name, settings)
      check_keys(settings, TIER_KEYS, "tier #{name}")
      check_string(settings["summary"], "tier #{name} summary")
      codex = tool_settings(name, settings, "codex")
      claude = tool_settings(name, settings, "claude")
      Tier.new(name:, summary: settings["summary"].strip,
               codex_model: codex["model"], codex_effort: codex["effort"],
               claude_model: claude["model"], claude_effort: claude["effort"])
    end

    def tool_settings(name, settings, tool)
      value = settings[tool]
      check_keys(value, TOOL_KEYS, "tier #{name} #{tool}")
      TOOL_KEYS.each { |key| check_string(value[key], "tier #{name} #{tool} #{key}") }
      value
    end

    def check_keys(value, keys, label)
      raise ArgumentError, "#{label} must be a mapping" unless value.is_a?(Hash)

      unknown = value.keys.map(&:to_s) - keys
      raise ArgumentError, "unknown keys in #{label}: #{unknown.join(", ")}" unless unknown.empty?

      missing = keys - value.keys
      raise ArgumentError, "missing keys in #{label}: #{missing.join(", ")}" unless missing.empty?
    end

    def check_string(value, label)
      return if value.is_a?(String) && !value.strip.empty?

      raise ArgumentError, "#{label} must be a non-empty string"
    end
  end
end
