# frozen_string_literal: true

require "tmpdir"
require "stringio"

# Shared temp project and Installer calls for installer and status tests.
module InstallerHelpers
  CODEX_PATH = ".codex/agents/sample_agent.toml"
  CLAUDE_PATH = ".claude/agents/sample_agent.md"

  def setup
    @dir = Dir.mktmpdir
    @agent = AgentFixture.agent
    @instructions = "## Delegating Rails work\n\nDelegate clearly."
  end

  def teardown
    FileUtils.remove_entry(@dir)
  end

  def installer(targets: %i[codex claude], agent: @agent)
    MyRubyCodingAgents::Installer.new(dir: @dir, agents: [agent], instructions: @instructions, targets:)
  end

  def install(targets: %i[codex claude], agent: @agent, **options)
    out = StringIO.new
    installer(targets:, agent:).install(out:, **options)
    out.string.lines(chomp: true)
  end

  def status(targets: %i[codex claude])
    out = StringIO.new
    clean = installer(targets:).status(out:)
    [clean, out.string.lines(chomp: true)]
  end

  def path(name) = File.join(@dir, name)

  def old_agent
    AgentFixture.agent(AgentFixture::SOURCE.sub("explain the workflow", "list the files"))
  end
end
