# frozen_string_literal: true

require "yaml"

module MyRubyCodingAgents
  # Parsed metadata and shared instruction body for one agent template.
  # Models and efforts come from the agent's tier in the Models table.
  class Agent
    FIELDS = %w[name description tier tools].freeze
    REQUIRED_FIELDS = %w[name description tier].freeze

    attr_reader :name, :description, :tier, :tools, :body

    # tier is a Models::Tier.
    def initialize(name:, description:, tier:, tools:, body:)
      @name = name
      @description = description
      @tier = tier
      @tools = Array(tools).flat_map { |tool| tool.to_s.split(/\s*,\s*/) }.freeze if tools
      @body = body.to_s.strip.freeze
      freeze
    end

    def codex_model = tier.codex_model
    def codex_effort = tier.codex_effort
    def claude_model = tier.claude_model
    def claude_effort = tier.claude_effort

    def self.parse(source, models:)
      metadata, body = split(source)
      check_fields(metadata.keys.map(&:to_s))
      new(name: metadata["name"], description: metadata["description"], tier: models.fetch(metadata["tier"]),
          tools: metadata["tools"], body:)
    end

    # Returns the frontmatter mapping and the body text.
    def self.split(source)
      match = source.match(/\A---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)\z/m)
      raise ArgumentError, "agent template must begin with YAML frontmatter" unless match

      metadata = YAML.safe_load(match[1], permitted_classes: [], aliases: false)
      raise ArgumentError, "agent frontmatter must be a mapping" unless metadata.is_a?(Hash)

      [metadata, match[2]]
    rescue Psych::Exception => e
      raise ArgumentError, "invalid agent frontmatter: #{e.message}"
    end
    private_class_method :split

    def self.check_fields(keys)
      unknown = keys - FIELDS
      raise ArgumentError, "unknown agent fields: #{unknown.join(", ")}" unless unknown.empty?

      missing = REQUIRED_FIELDS - keys
      raise ArgumentError, "missing agent fields: #{missing.join(", ")}" unless missing.empty?
    end
    private_class_method :check_fields

    def self.load(path, models:)
      parse(File.read(path), models:)
    rescue ArgumentError => e
      raise ArgumentError, "#{File.basename(path)}: #{e.message}"
    end
  end
end
