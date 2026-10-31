# Advisor plugin

A second-opinion workflow for Claude Code and Codex. The lead agent keeps doing the work. At key checkpoints it writes a briefing and consults the read-only `advisor` subagent, which runs on a stronger model, verifies the briefing against the code, and returns a verdict with guidance.

The plugin has three parts:

- `skills/advisor/SKILL.md`: the protocol. It defines `/advisor`, the four checkpoints, the briefing, and what to do with each verdict.
- `agents/advisor.md` and `agents/advisor.toml`: the subagent, rendered from the gem's `templates/agents/advisor.md`. Regenerate with `bundle exec rake plugins`.
- `hooks/hooks.json` and `scripts/advisor_hook.rb`: four hooks that give the skill memory and a reminder. `SessionStart` tells the model the mode is on, `PostToolUse` marks pending edits, `SubagentStop` logs each consult, and `Stop` nudges once when a turn ends with unreviewed edits.

The hook script needs `ruby` on PATH and uses only the standard library.

## Commands

| Command | Effect |
| --- | --- |
| `/advisor` | Turn the mode on for this project |
| `/advisor off` | Turn it off and delete `.advisor/` |
| `/advisor status` | Show the state |
| `/advisor ask <question>` | Consult now |
| `/advisor nudge off` | Disable the end-of-turn reminder |

State lives in `.advisor/` in the project. Enabling the mode adds that folder to `.git/info/exclude`. The folder is safe to delete.

## Install in Claude Code

For one session:

```sh
claude --plugin-dir path/to/my-ruby-coding-agents/plugins/advisor
```

To keep it, add this repository as a marketplace and install the plugin:

```sh
claude plugin marketplace add path/to/my-ruby-coding-agents
claude plugin install advisor@my-ruby-coding-agents
```

The plugin ships the `advisor` subagent in `agents/advisor.md`. If you also ran `my-ruby-coding-agents install --claude`, the project has the same agent in `.claude/agents/advisor.md`; delete one of the two.

## Install in Codex

Add this repository's marketplace and enable the plugin in the project's `.codex/config.toml`:

```sh
codex plugin marketplace add path/to/my-ruby-coding-agents
```

```toml
[plugins."advisor@my-ruby-coding-agents"]
enabled = true
```

Codex plugins carry skills and hooks, not subagents. Install the `advisor` agent with `my-ruby-coding-agents install --codex`, or copy `agents/advisor.toml` into `.codex/agents/`.

If your Codex version does not run plugin hooks, copy `hooks/hooks.json` to `.codex/hooks.json` and replace `${CLAUDE_PLUGIN_ROOT}` with the plugin's absolute path. Review the hooks with `/hooks` so Codex trusts them.

## Verdicts

The advisor answers with one of `proceed`, `proceed with changes`, or `stop`, followed by its reasons, recommendations with file references, risks to verify, numbered answers, and a confidence level. The lead reports each consult in one line and keeps the final call.
