# Focused Rails risk checks

Use these checks only when the changed behavior touches the area. First establish the project's Rails version, database adapter/version, and Active Job queue adapter from its dependency files, configuration, and deployment setup. Rails and adapter behavior varies; cite what the project actually uses and mark unavailable deployment or runtime evidence as unverified. This is a review aid, not a required design pattern or a complete audit.

## Queries and listings

- Compare query count and data volume across the relevant path, including loops, serializers, templates, and job batches. Check for N+1 behavior and whether association data is used; choose preloading only where needed.
- Distinguish loading records from counting them. Do not preload an association merely to count it, or replace a count with loading every row, without checking semantics and scale. Verify counter-cache or aggregate assumptions against the model and schema.
- Check that ordering is explicit and stable where callers rely on it, including a tie-breaker where needed. Check pagination boundaries, filters, and totals against the same scope and ordering; do not infer a particular pagination gem or strategy.

## Tenant, parameters, and jobs

- Follow the requested record from the entry point to the query. Confirm the lookup is scoped to the authenticated account/tenant where the application requires it, including nested resources and background work.
- Distinguish user-editable attributes from server-owned identity, ownership, state, and routing values. Verify strong parameters and assignment paths do not let a request select values that should come from trusted context.
- When work moves to a job, verify the required tenant/account context is explicit or reliably restored by the project's established mechanism. Check that retries and delayed execution cannot act on a different or no-longer-authorized context.

## Transactions, side effects, and delivery

- Trace the database transaction boundary for related writes and identify what remains committed after an error. Check callbacks and job enqueue timing against the Rails version and the application's actual transaction/job configuration.
- Separate database atomicity from external effects such as email, payment, or HTTP calls. Consider what happens if the effect succeeds but the database transaction rolls back, or if a retry repeats the effect.
- Check whether the job or operation is safe under the configured retry and duplicate/concurrent delivery behavior. Verify idempotency using the actual deduplication key/state and its database constraints; do not assume a queue adapter provides exactly-once execution.

## Migrations and deployment

- Check migration operations against the production database and table size: lock duration, table rewrite or index work, transaction behavior, and whether the operation is safe for the project's deployment window.
- For backfills, consider batch size, resumability, concurrent writes, and whether the migration is coupled to application code. Identify how long old and new application versions can overlap during rollout.
- Check constraint and index introduction order against existing data and concurrent traffic. Verify whether validation, concurrent index creation, or a staged add/backfill/validate sequence is supported by this Rails/database version; do not prescribe one universally.
- Check both compatibility directions needed during deployment: old code against the changed schema and new code while the backfill or rollout is incomplete. State which operational evidence (such as explain output, lock monitoring, or rollout procedure) is absent.

## Official Rails guides

- [Active Record Querying](https://guides.rubyonrails.org/active_record_querying.html): eager loading, calculations, ordering, and limiting results.
- [Active Job Basics](https://guides.rubyonrails.org/active_job_basics.html): queues, callbacks, retries, and job execution.
- [Security Guide](https://guides.rubyonrails.org/security.html): parameter filtering and mass assignment/strong parameters.
- [Active Record Migrations](https://guides.rubyonrails.org/active_record_migrations.html): migration operations, indexes, and database changes.

Use the guide matching the project's Rails version where available. The guides explain Rails behavior; they do not establish production database or queue-adapter guarantees for a particular application.
