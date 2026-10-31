# Advisor plugin

A second-opinion workflow for Claude Code and Codex. The lead agent keeps doing the work. At key checkpoints it writes a briefing and consults the read-only `advisor` subagent, which runs on a stronger model, verifies the briefing against the code, and returns a verdict with guidance.

The plugin has three parts:

- `skills/advisor/SKILL.md`: the protocol. It defines `/advisor`, the four checkpoints, the briefing, and what to do with each verdict.
- The `advisor` subagent is not in the plugin. `my-ruby-coding-agents install` writes it to `.claude/agents/advisor.md` and `.codex/agents/advisor.toml` from the gem's `templates/agents/advisor.md`.
- `hooks/hooks.json` and `scripts/advisor_hook.rb`: four hooks that give the skill memory and a reminder. `SessionStart` tells the model the mode is on, `PostToolUse` marks pending edits, `SubagentStop` logs each consult, and `Stop` nudges once when a turn ends with unreviewed edits.

Shell tools are tracked conservatively because a shell command can change files without an edit tool; read-only shell commands can therefore also trigger the reminder. Git exclusions are resolved through `git rev-parse`, which supports linked worktrees. If Git is unavailable or the directory is not a repository, the mode still works but `.advisor/` is not automatically excluded. Live hook behavior depends on the host application's hook support and was not integration-tested here.

The hook script needs `ruby` on PATH and uses only the standard library.

## Commands

| Command | Effect |
| --- | --- |
| `/advisor` | Turn the mode on for this project |
| `/advisor off` | Turn it off and delete `.advisor/` |
| `/advisor status` | Show the state |
| `/advisor ask <question>` | Consult now |
| `/advisor nudge off` | Disable the end-of-turn reminder |

State lives in `.advisor/` in the project. Enabling the mode adds that folder to Git's resolved `info/exclude` file, including in linked worktrees. The folder is safe to delete. History-dependent briefings must include the lead's Git output: the advisor labels it as supplied evidence and leaves shell commands to the lead.

## Install

The gem does it in one command, for both tools:

```sh
my-ruby-coding-agents install ./my-app --advisor
```

That writes the agents and the delegation guide, then runs the plugin commands below for each selected tool. Pass `--codex` or `--claude` to limit it, `--dry-run` to only print the commands, and `--advisor-source path/to/checkout` to use a local checkout of this repository as the marketplace.

### By hand in Claude Code

```sh
claude plugin marketplace add lucianghinda/my-ruby-coding-agents
claude plugin install advisor@my-ruby-coding-agents --scope project
```

For one session without any install, run `claude --plugin-dir path/to/plugins/advisor`.

### By hand in Codex

```sh
codex plugin marketplace add lucianghinda/my-ruby-coding-agents
codex plugin add advisor@my-ruby-coding-agents
```

Codex copies the plugin into `~/.codex/plugins/cache/` and enables it in `~/.codex/config.toml`. Review the hooks with `/hooks` so Codex trusts them. If your Codex version does not run plugin hooks, copy `hooks/hooks.json` to `.codex/hooks.json` and replace `${CLAUDE_PLUGIN_ROOT}` with the plugin's absolute path.

Codex plugins carry skills and hooks, not subagents, and the Claude Code plugin does not carry one either. The `advisor` agent comes from `my-ruby-coding-agents install`.

## Verdicts

The advisor answers with one of `proceed`, `proceed with changes`, or `stop`, followed by its reasons, recommendations with file references, risks to verify, numbered answers, and a confidence level. The lead reports each consult in one line and keeps the final call.
