import { tool } from "@opencode-ai/plugin"

// Commons backend project, relative to the session directory (repo root).
const BACKEND = "commons-packages/backend"

// Fixed test-DB connection params (see commons-packages/backend/src/models/knexfile_base.ts).
const PG = { host: "127.0.0.1", port: "5432", user: "root", password: "pwd", db: "commons_test" }

export default tool({
  description:
    "Reset the Commons test database (commons_test) when Jest fails with 'The migration directory is corrupt, the following files are missing: ...' or otherwise has stale migrations from a previously checked-out branch. This is an environment/shared-state issue, NOT a code defect. The tool drops and recreates the EMPTY database (initialize-test-db.ts connects to it directly and fails if it does not pre-exist), then repopulates schema.sql + runs knex migrations to latest. Use this instead of hand-rolling psql drops. The first repopulation run is slow (1-3 min); let it finish.",
  args: {
    confirm: tool.schema
      .boolean()
      .optional()
      .describe(
        "Set true to proceed. Drops and recreates commons_test (test data only — never touches dev/prod).",
      ),
  },
  async execute(args, context) {
    if (args.confirm === false) {
      return "Aborted: confirm was false. Re-run with confirm: true to reset commons_test."
    }

    const $ = Bun.$
    const env = { ...process.env, PGPASSWORD: PG.password }
    const psql = (database: string, sql: string) =>
      $`psql -h ${PG.host} -U ${PG.user} -p ${PG.port} -d ${database} -c ${sql}`.env(env).quiet()

    try {
      // 1. Drop (ignore if absent) then recreate an EMPTY database. initialize-test-db.ts
      //    connects to commons_test directly and errors if it does not already exist.
      await psql("postgres", "DROP DATABASE IF EXISTS commons_test;")
      await psql("postgres", "CREATE DATABASE commons_test;")

      // 2. Populate schema from schema.sql + run knex migrations to latest.
      const backendDir = `${context.directory}/${BACKEND}`
      await $`npx tsx ./src/__tests__/helpers/initialize-test-db.ts`
        .cwd(backendDir)
        .env({ ...env, NODE_ENV: "test" })
        .quiet()

      return "commons_test reset complete: dropped, recreated, schema + migrations applied. Re-run your test command."
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err)
      return `reset-test-db failed: ${message}\n\nManual fallback (from ${BACKEND}):\n  PGPASSWORD=pwd psql -h 127.0.0.1 -U root -d postgres -c "DROP DATABASE IF EXISTS commons_test;"\n  PGPASSWORD=pwd psql -h 127.0.0.1 -U root -d postgres -c "CREATE DATABASE commons_test;"\n  NODE_ENV=test npx tsx ./src/__tests__/helpers/initialize-test-db.ts`
    }
  },
})
