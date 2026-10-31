---
name: advisor
description: Advisor mode. The lead agent consults the read-only `advisor` subagent at checkpoints (before a major decision, when stuck, before declaring a change done) and keeps the final call. Use when the user types /advisor, asks to turn advisor mode on or off, asks for the advisor's status, or asks for a second opinion. Never turn the mode on by yourself.
argument-hint: "[on | off | status | ask <question> | nudge on|off]"
---

# Advisor mode

You keep doing the work and you make the final call. The `advisor` subagent is a stronger model that reads a briefing, verifies it against the code, and returns a verdict. It never edits files.

## State

Mode state lives in `.advisor/` in the project directory. The mode is on when `.advisor/state.json` has `"enabled": true`. Hooks keep the other fields current: `consults`, `advisor_agent_id`, and `last_consult_at`. `.advisor/log.md` holds every advisor response. Never stage or commit `.advisor/`.

Manage state with the plugin script. In Claude Code the plugin root is `${CLAUDE_PLUGIN_ROOT}`. In Codex it is the folder that holds `plugin.json`, two levels above this skill's folder.

```sh
ruby "<plugin root>/scripts/advisor_hook.rb" enable
ruby "<plugin root>/scripts/advisor_hook.rb" disable
ruby "<plugin root>/scripts/advisor_hook.rb" status
ruby "<plugin root>/scripts/advisor_hook.rb" nudge off
```

If the script is missing, write `.advisor/state.json` by hand with `{"enabled": true, "nudge": true, "consults": 0}`.

## Commands

- `/advisor` or `/advisor on`: enable the mode. Confirm in one line.
- `/advisor off`: disable the mode and delete `.advisor/`. Confirm in one line.
- `/advisor status`: report the state without changing it.
- `/advisor ask <question>`: consult now, at the `on request` checkpoint, whether or not the mode is on.
- `/advisor nudge on|off`: toggle the end-of-turn reminder. Default on.

When a task follows the command in the same message, run the command first, then the task.

A plain request for a second opinion is a one-off consult, not a mode change.

## Checkpoints

With the mode on, consult at these four checkpoints only:

1. **Before a major decision.** An architecture choice, a change that is hard to reverse or has a wide blast radius (migrations, public APIs, auth, payments, concurrency), or a materially ambiguous request. Consult once you have a concrete plan, not before.
2. **When stuck.** The same failure after two real fix attempts, behavior you cannot explain, or before a workaround such as a retry loop, a `sleep`, a broad `rescue`, or a skipped test.
3. **Before declaring done.** For logic changes, or edits that touch more than a couple of files. Trivial edits are exempt: say so in one line that starts with `Advisor:`.
4. **On request.** `/advisor ask` or a user request for the advisor's view.

Limits: no routine consults, at most one consult per checkpoint, and about four per task. Beyond that, split the task or ask the user.

## Briefing

Write the briefing from `references/briefing-template.md` next to this file. Include the user's request verbatim, what happened so far, verbatim evidence, the git state, numbered questions, and what you need back. Redact secrets.

## Consulting

- **Claude Code:** call the `advisor` subagent with the Agent tool in the foreground and wait for the result. If `advisor_agent_id` in the state file is set, send the briefing to that id with SendMessage so the advisor keeps its context, and send a delta briefing. If that fails, start a fresh advisor.
- **Codex:** ask Codex to have the `advisor` agent read the briefing and wait for its answer. Codex does not resume a finished subagent, so put the previous verdict in the `Previous consult` section of the briefing.

The subagent itself is not in this plugin. `my-ruby-coding-agents install` writes it to `.claude/agents/advisor.md` and `.codex/agents/advisor.toml`. If the `advisor` agent is not available, tell the user once and continue without it.

## Using the verdict

- `proceed`: continue.
- `proceed with changes`: apply the recommendations unless they conflict with the user's instructions or with facts you verified. Report what you skipped and why.
- `stop`: halt the plan and rethink. If the issue is a product or scope question, ask the user.

The advisor is a strong second opinion, not an authority. You stay accountable. You may show it evidence once, or overrule it with a stated reason. If the advisor asks for information, supply it once. Do not ping-pong.

After each consult, report in one or two lines:

```text
Advisor: <verdict>. <summary>. <action taken>.
```

Keep the full response out of chat unless the user asks for it.

## End-of-turn nudge

When files changed in a turn without a consult, a stop hook posts a message starting with `[Advisor]`. Respond by running the pre-completion checkpoint, or by stating in one line starting with `Advisor:` why it is not needed. The nudge fires at most once per batch of edits and stays quiet when you ended the turn with a question.

## Rules

- Never enable the mode unless the user asked.
- Never ask the advisor to edit files or to do the task.
- Never loop on the advisor: at most one follow-up per checkpoint.
- Never stage or commit `.advisor/`.
