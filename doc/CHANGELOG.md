## Unreleased

- Resolve advisor Git exclusions in linked worktrees and preserve existing
  exclusion entries without a trailing newline.
- Track shell tools as potential advisor edits, match advisor identities
  exactly (including plugin namespaces), and recover from malformed state.
- Make supplied history evidence explicit in advisor briefings while keeping
  the advisor's restricted tools.
- Add focused Rails risk checks to existing implementation, test, quality,
  and security roles, with version and adapter checks.
- Add three static Rails review tasks and retain measured plain-prompt versus
  role-template results, scoring criteria, and raw responses.

## [0.2.0] - 2026-10-31

- Add `code_archaeologist`, which researches part of a codebase and keeps
  notes in `docs/archaeology/`, and `pr_readiness_checker`, which checks whether open
  pull requests on a public repository are ready to merge, using `gh`, and
  reports without posting.
- Add the `review` model tier (Codex gpt-6.1-sol medium, Claude opus medium)
  for `pr_readiness_checker`.
- Add `advisor`, a read-only consultant for decisions before implementation,
  and the `advise` model tier (Codex gpt-6-astra medium, Claude fable medium)
  it uses. The delegation guide says when to consult it and when not to.
- Add `plugins/advisor`, a plugin for Claude Code and Codex with an `/advisor`
  skill, hooks, and a briefing template, so the lead consults the advisor at
  checkpoints and gets a nudge when it declares work done without one.
- Add `install --advisor`, which runs each tool's plugin commands to install the
  advisor plugin from this repository, and `--advisor-source` to point at a
  local checkout instead.

## [0.1.0] - 2026-10-30

First release.

- Add a CLI that installs ten Ruby and Rails coding agents for Codex
  (`.codex/agents/*.toml`) and Claude Code (`.claude/agents/*.md`) from one
  Markdown template per agent. Agents cover Ruby gems, libraries, and
  command-line tools as well as Rails applications.
- Add a delegation guide to `AGENTS.md` and `CLAUDE.md` between marker
  comments, so repeated installs replace the block instead of duplicating
  it. Skip `CLAUDE.md` when it imports `AGENTS.md` with an `@AGENTS.md`
  line. Write once when `CLAUDE.md` is a symlink to `AGENTS.md`.
- Route models through a tier table in `templates/models.yml` (`fast`,
  `investigate`, `implement`, `strong`). Each agent names a tier; the
  guide's model sentence is generated from the table. Claude uses Sonnet
  for routine work and Opus for security review.
- Stamp every generated agent file with a content hash. `install` refreshes
  unedited files, skips edited ones unless `--force` is given, and supports
  `--codex`, `--claude`, and `--dry-run`.
- Add `status` to report each file as missing, up to date, outdated, or
  edited. It exits 1 when an install is needed.
- Add `list` to show each agent's tier, models, efforts, and description.
- Tell every agent to start sub-agents with a fresh context window.
- Require Ruby 4.0 or newer. No runtime dependencies.
