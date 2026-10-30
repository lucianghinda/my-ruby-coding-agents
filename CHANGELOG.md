## [Unreleased]

- Add `code_archaeologist`, which researches part of a codebase and keeps
  notes in `docs/archaeology/`, and `pr_readiness_checker`, which checks whether open
  pull requests on a public repository are ready to merge, using `gh`, and
  reports without posting.
- Add the `review` model tier (Codex gpt-6.1-sol medium, Claude opus medium)
  for `pr_readiness_checker`.

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
