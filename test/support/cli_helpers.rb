# frozen_string_literal: true

require "stringio"
require "tmpdir"

# Runs the CLI with captured output for CLI tests.
module CLIHelpers
  # Returns the exit code, stdout text, and stderr text.
  def run_cli(*argv)
    out = StringIO.new
    err = StringIO.new
    code = MyRubyCodingAgents::CLI.run(argv, out:, err:)
    [code, out.string, err.string]
  end
end
