# frozen_string_literal: true

require "open3"

module MyRubyCodingAgents
  # Installs the advisor plugin into Codex and Claude Code by running each
  # tool's own marketplace and plugin commands. Both tools accept repeated
  # runs, so an install can be rerun safely.
  class PluginInstaller
    MARKETPLACE = "my-ruby-coding-agents"
    PLUGIN = "advisor@#{MARKETPLACE}".freeze
    DEFAULT_SOURCE = "lucianghinda/my-ruby-coding-agents"

    COMMANDS = {
      codex: ->(source) { [%W[codex plugin marketplace add #{source}], %W[codex plugin add #{PLUGIN}]] },
      claude: lambda do |source|
        [%W[claude plugin marketplace add #{source}], %W[claude plugin install #{PLUGIN} --scope project]]
      end
    }.freeze

    # Runs a command in dir. Returns [output, success] or nil when the
    # executable is not on PATH.
    DEFAULT_RUNNER = lambda do |argv, dir|
      output, status = Open3.capture2e(*argv, chdir: dir)
      [output, status.success?]
    rescue Errno::ENOENT
      nil
    end

    def initialize(dir:, targets:, source: DEFAULT_SOURCE, runner: DEFAULT_RUNNER)
      @root = File.expand_path(dir)
      @targets = COMMANDS.keys & Array(targets).map(&:to_sym)
      @source = source
      @runner = runner
    end

    # Runs the commands for every target. Returns true when none failed. A
    # tool missing from PATH is skipped, not failed.
    def install(out:, dry_run: false)
      @targets.all? { |target| install_target(target, out:, dry_run:) }
    end

    private

    def install_target(target, out:, dry_run:)
      COMMANDS.fetch(target).call(@source).each do |argv|
        out.puts("#{"would " if dry_run}run #{argv.join(" ")}")
        next if dry_run

        result = @runner.call(argv, @root)
        return skip(target, argv, out:) if result.nil?
        return failed(argv, result, out:) unless result[1]

        report(result, out:)
      end
      true
    end

    def skip(target, argv, out:)
      out.puts("skip #{target} plugin (#{argv.first} not found on PATH)")
      true
    end

    def failed(argv, result, out:)
      report(result, out:)
      out.puts("failed: #{argv.join(" ")}")
      false
    end

    def report(result, out:)
      text = result[0].to_s.strip
      out.puts(text) unless text.empty?
    end
  end
end
