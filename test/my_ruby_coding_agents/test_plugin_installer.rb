# frozen_string_literal: true

require "test_helper"
require "stringio"

class TestPluginInstaller < Minitest::Test
  CODEX = [%w[codex plugin marketplace add lucianghinda/my-ruby-coding-agents],
           %w[codex plugin add advisor@my-ruby-coding-agents]].freeze
  CLAUDE = [%w[claude plugin marketplace add lucianghinda/my-ruby-coding-agents],
            %w[claude plugin install advisor@my-ruby-coding-agents --scope project]].freeze

  def setup
    @calls = []
    @out = StringIO.new
  end

  def test_runs_both_commands_for_each_target_in_the_project_directory
    assert install(runner: recording { ["ok", true] })
    assert_equal CODEX + CLAUDE, @calls.map(&:first)
    assert_equal [Dir.pwd] * 4, @calls.map(&:last)
    assert_equal ["run #{CODEX[0].join(" ")}", "ok"], @out.string.lines(chomp: true).first(2)
  end

  def test_targets_and_source_narrow_the_commands
    assert install(targets: [:claude], source: "/tmp/checkout", runner: recording { ["", true] })
    assert_equal [%w[claude plugin marketplace add /tmp/checkout], CLAUDE[1]], @calls.map(&:first)
    assert_equal 2, @out.string.lines.length, "empty output is not printed"
  end

  def test_dry_run_prints_without_running
    assert install(dry_run: true, runner: recording { flunk "must not run" })
    assert_equal (CODEX + CLAUDE).map { |argv| "would run #{argv.join(" ")}" }, @out.string.lines(chomp: true)
  end

  def test_missing_tool_is_skipped_and_the_other_tool_still_runs
    runner = recording { |argv| argv.first == "codex" ? nil : ["ok", true] }
    assert install(runner:)
    assert_equal [CODEX[0]] + CLAUDE, @calls.map(&:first)
    assert_includes @out.string, "skip codex plugin (codex not found on PATH)"
  end

  def test_failed_command_stops_that_target_and_fails_the_install
    runner = recording { |argv| argv[2] == "marketplace" ? ["boom", false] : ["ok", true] }
    refute install(runner:)
    assert_equal [CODEX[0]], @calls.map(&:first), "stops at the first failure"
    assert_includes @out.string, "boom\nfailed: #{CODEX[0].join(" ")}"
  end

  def test_default_runner_reports_success_and_missing_executables
    output, ok = MyRubyCodingAgents::PluginInstaller::DEFAULT_RUNNER.call(%w[echo hi], Dir.pwd)
    assert ok
    assert_equal "hi\n", output
    assert_nil MyRubyCodingAgents::PluginInstaller::DEFAULT_RUNNER.call(%w[no-such-tool-xyz --help], Dir.pwd)
  end

  private

  def install(runner:, targets: %i[codex claude], source: MyRubyCodingAgents::PluginInstaller::DEFAULT_SOURCE,
              dry_run: false)
    MyRubyCodingAgents::PluginInstaller.new(dir: ".", targets:, source:, runner:).install(out: @out, dry_run:)
  end

  def recording(&block)
    lambda do |argv, dir|
      @calls << [argv, dir]
      block.call(argv)
    end
  end
end
