# frozen_string_literal: true

require "optparse"

module MyRubyCodingAgents
  # Handles the command line interface for installing, checking, and listing agents.
  class CLI
    def self.run(argv, out: $stdout, err: $stderr)
      new(argv, out:, err:).run
    end

    def initialize(argv, out:, err:)
      @argv = argv.dup
      @out = out
      @err = err
    end

    def run
      dispatch(@argv.shift) || 0
    rescue OptionParser::ParseError, ArgumentError => e
      @err.puts(e.message)
      2
    end

    private

    def dispatch(command)
      case command
      when "install" then install
      when "status" then status
      when "list" then list
      when "--version", "-v" then @out.puts(MyRubyCodingAgents::VERSION)
      when "--help", "-h", nil then @out.puts(help)
      else unknown_command(command)
      end
    end

    def unknown_command(command)
      @err.puts("Unknown command: #{command}")
      @err.puts(help)
      2
    end

    def install
      options = parse_options("install")
      return 0 if options[:help]

      installer(options).install(force: options[:force], dry_run: options[:dry_run], out: @out)
      0
    end

    # Exit 0 when every planned file is up to date, 1 otherwise.
    def status
      options = parse_options("status")
      return 0 if options[:help]

      installer(options).status(out: @out) ? 0 : 1
    end

    def parse_options(command)
      options = { targets: [], force: false, dry_run: false, help: false }
      option_parser(command, options).parse!(@argv)
      raise OptionParser::InvalidArgument, "expected at most one target directory" if @argv.length > 1

      options[:targets] = %i[codex claude] if options[:targets].empty?
      options
    end

    def option_parser(command, options)
      OptionParser.new do |opts|
        opts.banner = "Usage: my-ruby-coding-agents #{command} [DIR] [options]"
        opts.on("--codex", "Use Codex agents and AGENTS.md") { options[:targets] << :codex }
        opts.on("--claude", "Use Claude agents and CLAUDE.md") { options[:targets] << :claude }
        add_install_options(opts, options) if command == "install"
        opts.on("-h", "--help", "Show this help") { show_help(opts, options) }
      end
    end

    def add_install_options(opts, options)
      opts.on("--force", "Overwrite agent files, including edited ones") { options[:force] = true }
      opts.on("--dry-run", "Show planned writes without changing files") { options[:dry_run] = true }
    end

    def show_help(opts, options)
      @out.puts(opts)
      options[:help] = true
    end

    def installer(options)
      models = Templates.models
      agents = Templates.agents(models)
      Installer.new(dir: @argv.first || ".", agents:, instructions: Templates.instructions(models, agents),
                    targets: options[:targets])
    end

    def list
      Templates.agents(Templates.models).each { |agent| @out.puts(list_line(agent)) }
      0
    end

    def list_line(agent)
      [agent.name, agent.tier.name, "Codex: #{agent.codex_model} (#{agent.codex_effort})",
       "Claude: #{agent.claude_model} (#{agent.claude_effort})", agent.description].join(" | ")
    end

    def help
      <<~HELP
        Usage: my-ruby-coding-agents <command> [options]

        Commands:
          install [DIR]  Install or refresh agents and delegation instructions (default DIR: .)
          status [DIR]   Show which files are missing, outdated, edited, or up to date
          list           List bundled agents

        Options:
          --codex        Use Codex files only
          --claude       Use Claude Code files only
          --force        install: overwrite agent files, including edited ones
          --dry-run      install: show planned writes without changing files
          -v, --version  Show version
          -h, --help     Show this help

        install writes missing files and refreshes generated agent files nobody
        edited. It skips edited agent files unless --force is given.
        status exits 0 when everything is up to date and 1 otherwise.
      HELP
    end
  end
end
