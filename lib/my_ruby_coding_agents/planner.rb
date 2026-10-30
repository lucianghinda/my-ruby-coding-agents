# frozen_string_literal: true

module MyRubyCodingAgents
  # Works out which files an install would touch and the state of each one.
  # Install and status share this plan.
  class Planner
    # state is one of :missing, :up_to_date, :outdated, :edited (agent files),
    # :missing_block, :up_to_date, :outdated (instruction files), or :imported
    # (CLAUDE.md that imports AGENTS.md). note is extra text for output.
    Entry = Data.define(:path, :content, :kind, :state, :note)

    TARGETS = {
      codex: { dir: ".codex/agents", ext: "toml", guide: "AGENTS.md" },
      claude: { dir: ".claude/agents", ext: "md", guide: "CLAUDE.md" }
    }.freeze

    def initialize(root:, agents:, instructions:, targets:)
      @root = root
      @agents = agents
      @instructions = instructions
      @targets = TARGETS.keys & Array(targets).map(&:to_sym)
    end

    # Entries in install order. A linked CLAUDE.md and AGENTS.md refer to the
    # same file, so only the first entry for a real path is kept.
    def entries
      @targets.flat_map { |target| target_entries(target) }.uniq { |entry| identity(entry.path) }
    end

    private

    def target_entries(target)
      config = TARGETS.fetch(target)
      agents = @agents.map do |agent|
        path = File.join(@root, config[:dir], "#{agent.name}.#{config[:ext]}")
        agent_entry(path, Renderers.public_send(target, agent))
      end
      agents << guide_entry(target)
    end

    def agent_entry(path, content)
      Entry.new(path:, content:, kind: :agent, state: agent_state(path, content), note: nil)
    end

    def agent_state(path, content)
      return :missing unless File.exist?(path)

      existing = File.read(path)
      return :edited unless Generated.status(existing) == :unmodified

      existing == content ? :up_to_date : :outdated
    end

    def guide_entry(target)
      path = File.join(@root, TARGETS.dig(target, :guide))
      return instruction_entry(path) unless target == :claude && InstructionFile.imports_agents?(path)
      return instruction_entry(File.join(@root, "AGENTS.md"), note: "imported by CLAUDE.md") if @targets == [:claude]

      Entry.new(path:, content: nil, kind: :instructions, state: :imported, note: "imports AGENTS.md")
    end

    def instruction_entry(path, note: nil)
      existing = File.exist?(path) ? File.read(path) : nil
      content = InstructionFile.render(existing, @instructions)
      Entry.new(path:, content:, kind: :instructions, state: instruction_state(existing, content), note:)
    end

    def instruction_state(existing, content)
      return :missing_block unless InstructionFile.block?(existing)

      existing == content ? :up_to_date : :outdated
    end

    def identity(path)
      File.exist?(path) ? File.realpath(path) : path
    end
  end
end
