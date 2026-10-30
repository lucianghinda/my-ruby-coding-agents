# my-ruby-coding-agents

Install a shared set of Ruby and Rails coding agents into a project for Codex and
Claude Code. The gem keeps each agent's instructions in one Markdown template
and renders the tool-specific files for you.

The installer also adds a short delegation guide to `AGENTS.md` and
`CLAUDE.md`. It uses marker comments so later runs update the guide instead of
adding duplicates.

## Installation

Requires Ruby 4.0 or newer.

```sh
gem install my-ruby-coding-agents
```

Or add it to a bundle:

```sh
bundle add my-ruby-coding-agents
```

## Usage

Install both Codex and Claude Code agents into the current directory:

```sh
my-ruby-coding-agents install
```

Pass a project directory, choose one target, or preview the changes:

```sh
my-ruby-coding-agents install ./my-app --codex
my-ruby-coding-agents install ./my-app --claude
my-ruby-coding-agents install ./my-app --dry-run
```

`install` writes `.codex/agents/*.toml` and `.claude/agents/*.md`, plus the
delegation section in `AGENTS.md` and `CLAUDE.md`. The directory defaults to
`.`. `--codex` and `--claude` limit which tool's files are installed; with
neither flag, both targets are installed.

### Refreshing after a gem upgrade

Each generated agent file has a marker line with a hash of its content: a
`# my-ruby-coding-agents: <hash>` comment on the first line of the TOML file,
and an `<!-- my-ruby-coding-agents: <hash> -->` comment right after the
frontmatter of the Markdown file. Codex and Claude Code ignore these comments.
The installer uses the hash to tell a file nobody edited from an edited one.

Running `install` again applies these rules to each agent file:

| File state | Action |
| --- | --- |
| Missing | `write` |
| Generated, not edited, same as the gem | `skip ... (up to date)` |
| Generated, not edited, gem has a newer version | `update` |
| Edited by hand, or no marker | `skip ... (edited; use --force to overwrite)` |

So after a gem upgrade, a plain `install` refreshes every agent file you did
not edit and keeps your edits. Use `--force` to overwrite all agent files,
including edited ones:

```sh
my-ruby-coding-agents install ./my-app --force
```

Agent files installed by a version without markers count as edited. Run
`install --force` once to replace them with marked files.

`--dry-run` prints the same lines with a `would ` prefix (`would write`,
`would update`, `would overwrite`) and writes nothing.

The delegation section in `AGENTS.md` and `CLAUDE.md` sits between marker
comments. `install` adds it when missing and replaces only that block when it
is out of date; the rest of the file stays as is.

### Checking a project

`status` prints one line per file that `install` would manage, with its state:

```sh
my-ruby-coding-agents status ./my-app
my-ruby-coding-agents status ./my-app --codex
```

```text
up to date    .codex/agents/rails_explorer.toml
outdated      .codex/agents/test_designer.toml
edited        .claude/agents/rails_explorer.md
missing       .claude/agents/ui_implementer.md
missing block CLAUDE.md
```

Agent files are `missing`, `up to date`, `outdated` (not edited, but the gem
has a newer version), or `edited` (edited by hand or without a marker).
`AGENTS.md` and `CLAUDE.md` are `missing block`, `up to date`, or `outdated`.
`status` exits with 0 when everything is up to date and 1 otherwise, so you
can use it in CI.

### CLAUDE.md that imports AGENTS.md

Claude Code reads a line `@AGENTS.md` in `CLAUDE.md` as an import of
`AGENTS.md`. When `CLAUDE.md` has a line that is exactly `@AGENTS.md`
(surrounding spaces are fine), the installer does not add the block to
`CLAUDE.md`, since Claude Code already gets it through the import:

- With both targets (or with `--codex` too), it writes the block to
  `AGENTS.md` and reports `skip CLAUDE.md (imports AGENTS.md)`.
- With only `--claude`, it writes the block to `AGENTS.md` instead and
  reports `write AGENTS.md (imported by CLAUDE.md)`.

A linked `CLAUDE.md` that points to `AGENTS.md` is also written only once.

List the included agents with their tier, models, and efforts:

```sh
my-ruby-coding-agents list
```

Each line shows the agent name, tier, Codex model and effort, Claude model and
effort, and description:

```text
rails_explorer | fast | Codex: gpt-6-luna (low) | Claude: sonnet (low) | Trace a Ruby workflow ...
```

The ten agents are `rails_explorer`, `contract_mapper`, `test_designer`,
`rails_implementer`, `api_cli_implementer`, `evidence_reviewer`,
`quality_investigator`, `ui_implementer`, `security_mapper`, and
`security_reviewer`.

Use the generated delegation guide to choose a focused agent for independent
work. Handle small, coupled tasks yourself; parallelize independent bounded
tasks when the benefit outweighs coordination and token costs. Implementers
may add tests for their changes, with independent review for consequential
work. The names `rails_explorer` and `rails_implementer` also cover standalone
Ruby projects; the fleet keeps the same names across projects.

Models come from a tier table in `templates/models.yml`. Each tier (`fast`,
`investigate`, `implement`, `strong`) sets a model and reasoning effort for
Codex and for Claude, and each agent template names one tier with `tier:`.
Edit `templates/models.yml` to change routing; it is the one place model names
live. The installer builds the model sentence in the delegation guide from the
same table, so the guide, the agent files, and `list` always agree.

Model assignments are starting points, not benchmark-proven rankings. The lead
narrows ambiguous or unsuccessful tasks or uses a stronger available model;
there is no automatic model router.

## Development

After checking out the repository, run `bin/setup`, then `bundle exec rake` to
run the tests and RuboCop. `bundle exec rake docs` regenerates the Markdown API
docs in `doc/` and `llms.txt`; both ship inside the gem, so commit them.
`bin/prepare_release` runs the whole gate and builds the gem into `pkg/`.
`bundle exec rake branchproof` runs the tests under
[Branchproof](https://github.com/lucianghinda/branchproof) and lists decisions
in `lib/` that the tests do not fully exercise. CI runs the same analysis.

## License

Released under the MIT License. See [LICENSE.txt](LICENSE.txt).
