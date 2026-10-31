#!/usr/bin/env ruby
# frozen_string_literal: true

# Hook and state script for the advisor plugin. Works for Claude Code and Codex.
# Uses only the Ruby standard library and stays compatible with older Rubies,
# because it runs with whatever `ruby` is on PATH when a hook fires.
#
# Hook events (hook JSON on stdin):
#   advisor_hook.rb session_start | post_tool_use | subagent_stop | stop
# Commands the advisor skill runs:
#   advisor_hook.rb enable | disable | status | nudge on|off | clear
#
# State lives in .advisor/ inside the project directory: the hook's `cwd`
# field, or the current directory for commands.

require "json"
require "fileutils"
require "time"

# Reads and writes the files in .advisor/.
class AdvisorState
  DIR = ".advisor"
  DEFAULTS = { "enabled" => false, "nudge" => true, "consults" => 0, "advisor_agent_id" => nil }.freeze

  attr_reader :dir

  def initialize(root)
    @dir = File.join(root, DIR)
  end

  def state_path
    File.join(dir, "state.json")
  end

  def pending_path
    File.join(dir, "pending")
  end

  def log_path
    File.join(dir, "log.md")
  end

  def read
    return DEFAULTS.dup unless File.file?(state_path)

    DEFAULTS.merge(JSON.parse(File.read(state_path)))
  rescue JSON::ParserError
    DEFAULTS.dup
  end

  def write(state)
    FileUtils.mkdir_p(dir)
    File.write(state_path, "#{JSON.pretty_generate(state)}\n")
  end

  def enabled?
    read["enabled"] == true
  end

  def pending?
    File.file?(pending_path)
  end

  def mark_pending
    FileUtils.mkdir_p(dir)
    FileUtils.touch(pending_path)
  end

  def clear_pending
    FileUtils.rm_f(pending_path)
  end

  def append_log(title, body)
    FileUtils.mkdir_p(dir)
    File.open(log_path, "a") { |f| f.puts("## #{Time.now.utc.iso8601} #{title}", "", body.to_s.strip, "") }
  end

  # Counts a consult, remembers the advisor id, logs its answer, and clears pending edits.
  def record_consult(agent_type, agent_id, message)
    state = read
    state["consults"] = state["consults"].to_i + 1
    state["advisor_agent_id"] = agent_id unless agent_id.to_s.empty?
    state["last_consult_at"] = Time.now.utc.iso8601
    write(state)
    append_log(agent_type, message)
    clear_pending
  end

  def remove
    FileUtils.rm_rf(dir)
  end
end

# Runs one hook event or one skill command.
class AdvisorHook
  EVENTS = %w[session_start post_tool_use subagent_stop stop].freeze
  NUDGE = "[Advisor] Files changed in this turn without an advisor consult. Run the pre-completion " \
          "checkpoint from the advisor skill, or reply with one line starting with `Advisor:` that says " \
          "why it is not needed."

  def self.run(argv, stdin: $stdin, stdout: $stdout)
    new(argv, stdin: stdin, stdout: stdout).run
  end

  def initialize(argv, stdin:, stdout:)
    @command = argv[0].to_s
    @argument = argv[1].to_s
    @stdin = stdin
    @stdout = stdout
  end

  def run
    if EVENTS.include?(@command)
      @input = parse_input
      @state = AdvisorState.new(@input["cwd"].to_s.empty? ? Dir.pwd : @input["cwd"])
      send(@command)
    else
      @state = AdvisorState.new(Dir.pwd)
      command
    end
    0
  end

  private

  def parse_input
    raw = @stdin.read.to_s
    raw.strip.empty? ? {} : JSON.parse(raw)
  rescue JSON::ParserError
    {}
  end

  # Tells the model that the mode is on. Plain stdout becomes context in both tools.
  def session_start
    return unless @state.enabled?

    @stdout.puts "[Advisor] Advisor mode is on for this project (#{@state.read["consults"]} consults so far). " \
                 "Load the `advisor` skill and follow its checkpoints."
  end

  def post_tool_use
    @state.mark_pending if @state.enabled?
  end

  def subagent_stop
    return unless @state.enabled? && @input["agent_type"].to_s.include?("advisor")

    @state.record_consult(@input["agent_type"], @input["agent_id"], @input["last_assistant_message"])
  end

  # Nudges once per batch of edits when the turn ends without a consult.
  def stop
    state = @state.read
    return unless state["enabled"] == true && state["nudge"] == true && @state.pending?
    return if @input["stop_hook_active"] == true

    message = @input["last_assistant_message"].to_s
    return if message.strip.end_with?("?")

    @state.clear_pending
    return if message.match?(/^\s*Advisor\b/)

    @stdout.puts JSON.generate("decision" => "block", "reason" => NUDGE)
  end

  def command
    case @command
    when "enable" then enable
    when "disable" then disable
    when "status" then status
    when "nudge" then nudge
    when "clear" then @state.clear_pending
    else
      @stdout.puts "usage: advisor_hook.rb #{(EVENTS + %w[enable disable status nudge clear]).join("|")}"
    end
  end

  def enable
    state = @state.read
    state["enabled"] = true
    state["enabled_at"] ||= Time.now.utc.iso8601
    @state.write(state)
    exclude_from_git
    @stdout.puts "Advisor mode on. State: #{AdvisorState::DIR}/state.json"
  end

  def disable
    @state.remove
    @stdout.puts "Advisor mode off."
  end

  def status
    state = @state.read
    @stdout.puts "enabled: #{state["enabled"]}", "nudge: #{state["nudge"]}", "consults: #{state["consults"]}",
                 "advisor_agent_id: #{state["advisor_agent_id"] || "none"}", "pending edits: #{@state.pending?}"
  end

  def nudge
    state = @state.read
    state["nudge"] = (@argument != "off")
    @state.write(state)
    @stdout.puts "Nudge #{state["nudge"] ? "on" : "off"}."
  end

  # Keeps .advisor/ out of commits without touching the tracked .gitignore.
  def exclude_from_git
    info = File.join(Dir.pwd, ".git", "info")
    return unless File.directory?(File.join(Dir.pwd, ".git"))

    FileUtils.mkdir_p(info)
    exclude = File.join(info, "exclude")
    lines = File.file?(exclude) ? File.readlines(exclude, chomp: true) : []
    return if lines.include?("#{AdvisorState::DIR}/")

    File.open(exclude, "a") { |f| f.puts "#{AdvisorState::DIR}/" }
  end
end

exit AdvisorHook.run(ARGV) if $PROGRAM_NAME == __FILE__
