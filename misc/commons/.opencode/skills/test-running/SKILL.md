---
name: test-running
description: Advanced Jest test modes in the Commons monorepo — /local/ tests, watch mode, live console output, multi-file batching, and test-failure troubleshooting. For routine "run the test for this file" resolution, call the nx-project-for-file tool instead.
---

# Advanced Jest Test Modes

> **Project + command resolution:** Call the `nx-project-for-file` tool with the test
> file path. It returns the owning project, root, and the exact
> `npx nx test:jest:run <project> -- --runTestsByPath <relative-path>` command.
> This skill covers only the modes the tool does **not** emit.

## `/local/` tests — different target

The tool emits `test:jest:run`. If the test path contains `/local/`, swap the target
to `test-local:jest:run`:

```bash
npx nx test-local:jest:run <project> -- --runTestsByPath <relative-path>
```

| File Path | Target |
|-----------|--------|
| `packages/athena/__tests__/local/workflow.spec.ts` | `test-local:jest:run` |
| `commons-packages/backend/__tests__/services/member.spec.ts` | `test:jest:run` |

## Running multiple files (batching)

Same project, same target — pass multiple paths in one invocation:

```bash
npx nx test:jest:run @commons/backend -- --runTestsByPath __tests__/a.spec.ts __tests__/b.spec.ts
```

## Running all tests for a project

Omit `--runTestsByPath`:

```bash
npx nx test:jest:run @commons/backend
```

## Console output (debugging)

By default console output is captured and only shown on failure. For live output:

```bash
COMMONS_TESTING_LOG_LEVEL=live npx nx test:jest:run <project> -- --runTestsByPath <path>
```

Log levels: `error` (default) | `warn` | `info` | `live`

## Watch mode

```bash
npx nx test:jest:run @commons/backend -- --runTestsByPath __tests__/my.spec.ts --watch
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| EPERM errors | Run with sandbox disabled (permission issues with npm/node modules) |
| Test not found | Verify path is relative to **project root**, not repo root (the tool returns the correct relative path) |
| `/local/` tests not running | Use `test-local:jest:run` target instead of `test:jest:run` |
| `The migration directory is corrupt, the following files are missing: ...` | Stale shared test DB — `commons_test` holds migrations from another branch you previously checked out. This is an **environment** issue, NOT a code defect; do not investigate your changeset. Reset the DB (see below). |

## Resetting a stale/corrupt test DB

Jest uses a shared `commons_test` Postgres DB (host `127.0.0.1`, port `5432`, user `root`,
password `pwd`). Switching branches can leave it with migration records for files absent from
your tree, so `knex.migrate.latest()` fails in `beforeAll` with `migration directory is
corrupt`. This is shared-state drift, not your code.

Prefer the **`reset-test-db` tool** if available — it performs the steps below in the correct
order. Otherwise run, from `commons-packages/backend`:

```bash
# 1. Recreate an EMPTY database. initialize-test-db.ts connects to commons_test directly and
#    fails if it does not already exist, so you must CREATE it empty before repopulating.
PGPASSWORD=pwd psql -h 127.0.0.1 -U root -d postgres -c "DROP DATABASE IF EXISTS commons_test;"
PGPASSWORD=pwd psql -h 127.0.0.1 -U root -d postgres -c "CREATE DATABASE commons_test;"
# 2. Populate schema from schema.sql + run migrations to latest. First run is slow (1-3 min);
#    let it finish — do not abort it, or the DB is left half-initialized.
NODE_ENV=test npx tsx ./src/__tests__/helpers/initialize-test-db.ts
```

To confirm a foreign-branch migration is the culprit before resetting:

```bash
git log --all --oneline -- "**/<missing-migration-file>"
```
