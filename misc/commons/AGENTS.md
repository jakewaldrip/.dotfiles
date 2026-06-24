# Commons Monorepo

Repo-specific rules for working in this codebase. These supplement the global
conventions and take precedence for anything Commons-specific.

## Database Schema

- **NEVER edit `commons-packages/backend/schema.sql`.** It is a generated/maintained
  artifact and must not be hand-modified as part of agent work. Schema changes flow
  exclusively through knex migrations (see the `database-migration` skill). If
  `schema.sql` appears in your `git status`, revert it
  (`git checkout -- commons-packages/backend/schema.sql`).
- **Always create migration files with `pnpm run migrate:make {migration_name}`**
  (run in `commons-packages/backend`). This only writes a correctly-timestamped
  scaffold file and does NOT require a database connection. Never hand-author a
  migration file or invent its timestamp.

## Code Comments

- Default to **minimal comments**. Lean toward removal. Do not add comments that
  restate what the code plainly does.
- Keep a comment only when it captures a **non-obvious decision** (a "why", a
  spec/AC reference, a subtle invariant). When in doubt, leave it out.

## Validation Cadence

- Run `tsc` (and scoped ESLint) **after each cohesive surface is changed**, not only
  at the very end. For multi-surface work (e.g., provider UI + CDI view), typecheck
  the first surface before starting the second so prop/type mismatches surface early.
- Remember `tsc` reports only the first errors per file; after fixing, **re-run to
  completion** before declaring green.
- To resolve which Nx project owns a file and the exact typecheck/lint/test commands,
  **call the `nx-project-for-file` tool** — do not hand-roll `nx graph`/`jq` or guess
  target names (the typecheck target is `lint:tsc:check`, not `typecheck`). Load the
  `test-running` / `lint-running` skills only for advanced modes (`/local/` tests,
  watch, live logs, git-affected linting, auto-fix, the full-CI lint pipeline).
