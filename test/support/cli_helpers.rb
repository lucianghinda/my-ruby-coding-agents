# frozen_string_literal: true

require "stringio"
require "tmpdir"

# Runs the CLI with captured output for CLI tests.
module CLIHelpers
  # Returns the exit code, stdout text, and stderr text.
  def run_cli(*argv, plugin_runner: MyRubyCodingAgents::PluginInstaller::DEFAULT_RUNNER)
    out = StringIO.new
    err = StringIO.new
    code = MyRubyCodingAgents::CLI.run(argv, out:, err:, plugin_runner:)
    [code, out.string, err.string]
  end
end
