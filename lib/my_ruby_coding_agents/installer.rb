# frozen_string_literal: true

require "fileutils"

module MyRubyCodingAgents
  # Writes planned files and reports the state of each one.
  class Installer
    START_MARKER = InstructionFile::START_MARKER
    END_MARKER = InstructionFile::END_MARKER

    WRITE_VERBS = { missing: "write", missing_block: "write", outdated: "update", edited: "overwrite" }.freeze
    SKIP_REASONS = { up_to_date: "up to date", edited: "edited; use --force to overwrite",
                     imported: "imports AGENTS.md" }.freeze
    STATUS_LABELS = { missing: "missing", missing_block: "missing block", up_to_date: "up to date",
                      outdated: "outdated", edited: "edited", imported: "skipped" }.freeze
    CLEAN_STATES = %i[up_to_date imported].freeze

    def initialize(dir:, agents:, instructions:, targets:)
      @root = File.expand_path(dir)
      @planner = Planner.new(root: @root, agents:, instructions:, targets:)
    end

    # Writes missing and outdated files. Edited agent files are kept unless
    # force is true. Returns the number of planned files.
    def install(out:, force: false, dry_run: false)
      entries = @planner.entries
      entries.each { |entry| apply(entry, force:, dry_run:, out:) }
      entries.length
    end

    # Prints one state line per planned file. Returns true when nothing needs
    # an install.
    def status(out:)
      entries = @planner.entries
      entries.each { |entry| out.puts("#{STATUS_LABELS.fetch(entry.state).ljust(13)} #{describe(entry)}") }
      entries.all? { |entry| CLEAN_STATES.include?(entry.state) }
    end

    private

    def apply(entry, force:, dry_run:, out:)
      if skip?(entry, force)
        out.puts("skip #{relative(entry.path)} (#{SKIP_REASONS.fetch(entry.state)})")
        return
      end

      out.puts("#{"would " if dry_run}#{WRITE_VERBS.fetch(entry.state)} #{describe(entry)}")
      write(entry) unless dry_run
    end

    def skip?(entry, force)
      CLEAN_STATES.include?(entry.state) || (entry.state == :edited && !force)
    end

    def write(entry)
      FileUtils.mkdir_p(File.dirname(entry.path))
      File.write(entry.path, entry.content)
    end

    def describe(entry)
      entry.note ? "#{relative(entry.path)} (#{entry.note})" : relative(entry.path)
    end

    def relative(path)
      path.delete_prefix("#{@root}/")
    end
  end
end
