# frozen_string_literal: true

module MyRubyCodingAgents
  # Builds AGENTS.md and CLAUDE.md content with the managed delegation block.
  module InstructionFile
    START_MARKER = "<!-- my-ruby-coding-agents:start -->"
    END_MARKER = "<!-- my-ruby-coding-agents:end -->"
    BLOCK = /#{Regexp.escape(START_MARKER)}.*?#{Regexp.escape(END_MARKER)}/m
    # A CLAUDE.md line that imports AGENTS.md in Claude Code.
    IMPORT = /^[ \t]*@AGENTS\.md[ \t]*\r?$/

    module_function

    # Replaces the block in existing content, or appends it. existing may be nil.
    def render(existing, instructions)
      block = "#{START_MARKER}\n#{instructions.to_s.strip}\n#{END_MARKER}"
      existing = existing.to_s
      return existing.sub(BLOCK) { block } if block?(existing)

      "#{[existing.rstrip, block].reject(&:empty?).join("\n\n")}\n"
    end

    def block?(content)
      content.to_s.match?(BLOCK)
    end

    def imports_agents?(path)
      File.file?(path) && File.read(path).match?(IMPORT)
    end
  end
end
