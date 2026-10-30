## Delegating Ruby and Rails work

Default to handling small, coupled tasks yourself. Parallelize independent, bounded work only when the benefit outweighs the token and coordination cost. Use no more than five concurrent subagents, not counting the lead. Keep the work moving instead of raising unnecessary blockers, and keep updates concise. At the end of each turn reporting on long-running or delegated work, use this format and write `None` when no user action is needed:

```text
Goal: …
Done: …
Next: …
Needs you: …
```

When independent work would benefit from a subagent, use the role that matches the task:
- `rails_explorer`: focused, read-only codebase questions.
- `contract_mapper`: compare browser, API, and CLI paths.
- `test_designer`: design or implement tests without changing application code.
- `rails_implementer`: implement Ruby library, gem, CLI, and Rails application behavior.
- `api_cli_implementer`: implement API and command-line behavior.
- `evidence_reviewer`: trace source data, attribution, revisions, and derived records.
- `quality_investigator`: investigate issues using the project's quality tools.
- `ui_implementer`: implement interface changes using project design guidance.
- `security_mapper`: map security-sensitive flows and trust boundaries.
- `security_reviewer`: review changes for security defects.
- `code_archaeologist`: research how part of the code works and record it in `docs/archaeology/`.
- `pr_readiness_checker`: check whether open pull requests on a public repository are ready to merge; it reports and never posts.

Rules:
- Model assignments are starting points. {{model_routing}} For ambiguous tasks or inadequate results, the lead should narrow the task or use a stronger available model rather than repeat the same unsuccessful approach. This gem installs defaults; it does not select models at runtime.
- An implementer may add or update tests for their change. For consequential changes, arrange an independent review rather than requiring a separate agent to author every test.
- No two agents edit the same files at the same time. Give each agent a specific task and review its evidence.
- Start every sub-agent with a fresh context window.
