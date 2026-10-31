# Pilot results — 2026-10-31

**Result: no observed defect-detection improvement on these three tasks.** Both
conditions found all six seeded defects with the required fixes and proposed
concrete regression checks for all six. The role condition took 27.259 seconds
in total versus 24.613 seconds for plain prompts, approximately 10.8% longer.
These totals sum overlapping agent intervals; they are not the wall time to run
the whole experiment and do not establish a model-latency difference.

| Task | Plain defects | Role defects | Plain checks | Role checks | Plain seconds | Role seconds |
| --- | --- | --- | --- | --- | --- | --- |
| Account-isolated documents | 2/2 | 2/2 | 2/2 | 2/2 | 6.878 | 6.857 |
| Retryable invoice charging | 2/2 | 2/2 | 2/2 | 2/2 | 6.489 | 9.670 |
| Order listing performance and pagination | 2/2 | 2/2 | 2/2 | 2/2 | 11.246 | 10.732 |

No additional unsupported *confirmed* defect was identified in the six
responses. Qualified concerns about deep OFFSET costs and provider idempotency
semantics were kept as uncertainties. Some line references are approximate;
the tenant-role response points near the parameter helper rather than to the
exact `permit` line. Scores assess the specified defect/fix and check criteria,
not citation accuracy or prose quality.

## Scoring evidence

The rubric in [rubric.json](../../rubric.json) was saved before any agent run.
The lead scored the responses, then a separate fresh-context Luna reviewer
independently checked all six and agreed on defect/check coverage. This was
model-based scoring, not blinded human scoring or an executable acceptance test.

- **Documents, both conditions:** identified the global read and recommended
  `current_account.documents.find`; identified client-controlled `account_id`
  and recommended removing it. Both proposed a foreign-account read test and an
  ownership-preservation update test.
- **Invoice job, both conditions:** identified repeated external charges after
  gateway success/database failure and recommended a stable provider idempotency
  key. Both also found the timeout rescue bypassing `retry_on` and recommended
  propagating the exception. Proposed checks cover redelivery and timeout retry.
- **Order listing, both conditions:** identified customer queries and per-order
  `line_items.count`, with customer preloading plus grouped counts. Both found
  unstable ordering at tied timestamps and recommended a unique tie-breaker.
  Proposed checks cover bounded query growth and repeated adjacent pages.

Raw responses and agent-recorded UTC timestamps are retained unchanged:

- Documents: [plain](tenant_documents-plain.json), [role](tenant_documents-role.json).
- Invoice job: [plain](invoice_job-plain.json), [role](invoice_job-role.json).
- Order listing: [plain](order_listing-plain.json), [role](order_listing-role.json).

[inputs.json](inputs.json) records SHA-256 hashes of the fixtures, role templates,
task requests, and rubric used for this run. The roles in this run are
`security_reviewer`, `rails_implementer`, and `quality_investigator`.

## Run conditions and limits

Each response came from a separate native Codex subagent, explicitly selected
as `gpt-6-luna`, without inherited conversation history. Reasoning effort was
the host default, not separately controlled or reported. No role-tier model
was substituted. No application tests or Rails runtime were executed. Token
usage and dollar cost were unavailable and are not estimated.

There were two waves. First: document/plain, invoice/role, listing/plain.
Second: document/role, invoice/plain, listing/role. The condition order was
alternated across tasks, not randomized; each wave ran concurrently. Common
instructions asked for confirmed defects, evidence, minimal fixes, concrete
checks, and explicit uncertainties. Task requests are retained in
[tasks.json](../../tasks.json); see the [protocol](../../README.md) for controls.

This is one run per condition on deliberately small excerpts with visible
assumptions. Both prompts hit the scoring ceiling, so the pilot cannot show
whether the checklists help on harder or unfamiliar changes. Timing includes
input reading, tool overhead, and review composition, bounded by agent-recorded
timestamps; it excludes startup before the first timestamp and result-file
serialization after the last. Role runs also read one additional input file.
The fixture/checklist authors knew the seeded defects. The same shared host
supplied system instructions and tools in every condition. These limitations
rule out claims of improved productivity, statistical significance, runtime
correctness, or end-to-end plugin reliability.

Use this as an auditable starting point for repeated, independently scored
reviews of real changes. The observed result gives no reason to add more roles.
