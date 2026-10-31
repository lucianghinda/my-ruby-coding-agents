# frozen_string_literal: true

module MyRubyCodingAgents
  # Usage text for the command line interface.
  module CLIHelp
    TEXT = <<~HELP.freeze
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
        --advisor      install: also install the advisor plugin into Codex and Claude Code
        --advisor-source SOURCE
                       install: marketplace source for --advisor
                       (default: #{PluginInstaller::DEFAULT_SOURCE})
        -v, --version  Show version
        -h, --help     Show this help

      install writes missing files and refreshes generated agent files nobody
      edited. It skips edited agent files unless --force is given.
      status exits 0 when everything is up to date and 1 otherwise.
      install --advisor runs `plugin marketplace add` and the plugin install
      command of each selected tool. A tool missing from PATH is skipped, and
      a failed command exits 1.
    HELP
  end
end
