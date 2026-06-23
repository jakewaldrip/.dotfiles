---
name: create-job
description: Create job files in the Commons monorepo. Use when the user wants to create a new job, backfill script, cache job, export job, sync job, bulk operation, cron task, or any background task that runs via HTTP POST endpoint.
---

# Create Job

Create background jobs that run as HTTP POST endpoints in the Commons worker.

## How Jobs Work

- Files in `commons-packages/backend/src/jobs/` are **auto-discovered by filename**
- Available as `HTTP POST /jobs/<filename-without-extension>`
- The handler in `script-execute-handler.ts` dynamically `require()`s the file and wraps it in `BatchJobRun.trap()` for lifecycle tracking
- Legacy paths `/scripts/<slug>` and `/cron/<slug>` also work but `/jobs/` is preferred
- Cloud Scheduler cron jobs: **filename must match the Cloud Scheduler job name**

## When to Use

- Backfilling data, caching external data, bulk operations, exports, syncs, workflow triggers, data cleanup, scheduled cron tasks

## When NOT to Use

- **Schema changes** → use @database-migration
- **One-off data queries** → provide SQL to the user

## File Location

`commons-packages/backend/src/jobs/{kebab-case-name}.ts`

Tests: `commons-packages/backend/src/jobs/__tests__/{kebab-case-name}.spec.ts`

Shared helpers: `commons-packages/backend/src/jobs/shared/` or `commons-packages/backend/src/jobs/helpers/`

## Job Categories and Naming

| Category | Prefix | Use Case |
|----------|--------|----------|
| Backfill | `backfill-` | Populate or fix existing data |
| Cache/ETL | `cache-` | Sync external data (BigQuery, APIs) into local tables |
| Export | `export-` | Generate files (CSV, PDF) and upload to GCS |
| Bulk operation | `bulk-` | Batch create/delete/update operations |
| Sync | `sync-` | Two-way data synchronization |
| Create | `create-` | Provision new records |
| Delete | `delete-` | Remove or soft-delete records |
| Update | `update-` | Modify existing records |
| Start workflow | `start-` | Trigger workflow creation for eligible patients |
| Cleanup | `cleanup-` | Fix data inconsistencies, remove duplicates |
| Cancel | `cancel-` | Cancel workflows or scheduled items |

## Core Types

From `commons-packages/backend/src/jobs/helpers.ts`:

```typescript
// The canonical handler type — all jobs should conform to this
type ScriptHandler = (req: express.Request) => Promise<JSONData | undefined | void>;

// Throw to return a specific HTTP status code (e.g., 400 for bad input)
class StatusError extends Error { status: number; data: JSONData; }

// Subclass of StatusError — job is marked successful even when thrown
class AcceptableError extends StatusError {}
```

## Standard Job Template

```typescript
import type { Request } from 'express';
import { z } from 'zod';
import logger from '@commons/backend/lib/logging.js';
import type { ScriptHandler } from '@commons/backend/jobs/helpers.js';
import { StatusError } from '@commons/backend/jobs/helpers.js';

const TAG = 'job-name';

const RequestBody = z.object({
  exampleParam: z.string(),
  optionalParam: z.number().optional().default(100),
});

// Named export for testability
export const jobName = async (body: unknown) => {
  const bodyResult = RequestBody.safeParse(body);
  if (!bodyResult.success) {
    logger.error(bodyResult.error, { tag: TAG });
    throw new StatusError(400, 'Invalid request body');
  }

  const { exampleParam, optionalParam } = bodyResult.data;
  logger.log(`Starting job with param=${exampleParam}`, TAG);

  // ... business logic ...

  const result = { processed: 0, succeeded: 0, failed: 0 };
  logger.log('Job complete', TAG, result);
  return result;
};

// Default export — thin wrapper required by the job handler
const main: ScriptHandler = async (req) => jobName(req.body);
export default main;
```

## Backfill Job Template (with dry-run + batching)

```typescript
import type { Request } from 'express';
import { z } from 'zod';
import logger from '@commons/backend/lib/logging.js';
import type { ScriptHandler } from '@commons/backend/jobs/helpers.js';
import { StatusError } from '@commons/backend/jobs/helpers.js';
import knex from '@commons/backend/lib/knex.js';

const TAG = 'backfill-entity-name';

const RequestBody = z.object({
  batchSize: z.number().optional().default(1000),
  limit: z.number().optional(),
  isDryRun: z.boolean().optional().default(false),
});

export const backfillEntityName = async (body: unknown) => {
  const bodyResult = RequestBody.safeParse(body);
  if (!bodyResult.success) {
    logger.error(bodyResult.error, { tag: TAG });
    throw new StatusError(400, 'Invalid request body');
  }

  const { batchSize, limit, isDryRun } = bodyResult.data;
  let totalProcessed = 0;

  while (limit === undefined || totalProcessed < limit) {
    const currentBatchSize = limit !== undefined
      ? Math.min(batchSize, limit - totalProcessed)
      : batchSize;

    const batch = await knex('table_name')
      .select('*')
      .whereNull('targetColumn')
      .limit(currentBatchSize);

    if (batch.length === 0) break;

    if (!isDryRun) {
      // ... perform writes ...
    }

    totalProcessed += batch.length;
    logger.log(`Processed ${totalProcessed} records`, TAG, { isDryRun });
  }

  return { isDryRun, batchSize, limit, totalProcessed };
};

const main: ScriptHandler = async (req) => backfillEntityName(req.body);
export default main;
```

## Rules

1. **Default export** must be `async (req: Request) => Promise<JSONData | undefined | void>`
2. **Use `ScriptHandler` type** from `@commons/backend/jobs/helpers.js` for type annotation
3. **Validate body with Zod** using `safeParse`; throw `new StatusError(400, ...)` on failure
4. **Export a named function** with business logic separate from the default export for testability
5. **Kebab-case filenames** — the filename becomes the URL slug
6. **Define a TAG constant** for all `logger` calls: `const TAG = 'job-file-name';`
7. **Import logger** from `@commons/backend/lib/logging.js`
8. **Per-item try/catch** — when processing multiple items, catch errors per item, log them, and continue
9. **Return a summary object** with counts: `{ processed, succeeded, failed }` or similar
10. **Dry-run support** — for backfills and destructive operations, accept `isDryRun` param and skip writes when true
11. **Batching** — use `batchSize` + `limit` params with a `while` loop or chunked iteration
12. **All `.js` import extensions** — use `.js` extensions in import paths (TypeScript with ESM resolution)
13. **No `jsonSchema`** — use Zod for request body validation, not JSON Schema

## Testing Patterns

- **Unit tests**: Mock models/services with `jest.mock()`, call the named export directly
- **Integration tests**: Use factory functions from `@commons/backend/__tests__/helpers/factories/`, call the named export
- **Request builder**: `const buildRequest = (body: any) => ({ body }) as any;` for calling the default export

```typescript
import { jobName } from '@commons/backend/jobs/job-name.js';

describe('jobName', () => {
  it('processes records correctly', async () => {
    // Setup with factories or mocks
    const result = await jobName({ exampleParam: 'value' });
    expect(result).toEqual({ processed: 1, succeeded: 1, failed: 0 });
  });

  it('rejects invalid input', async () => {
    await expect(jobName({})).rejects.toThrow();
  });
});
```

## Invocation

```bash
# Local
curl -X POST "http://localhost:8080/jobs/your-job-name" \
  -H "Content-Type: application/json" \
  -d '{"exampleParam": "value"}'

# Staging/Production (requires API Caller permission)
curl -X POST "https://commons-staging.cityblock.com/jobs/your-job-name" \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{"exampleParam": "value"}'
```

## Reference

- Job handler: `commons-packages/backend/src/handlers/script-execute-handler.ts`
- Helper types: `commons-packages/backend/src/jobs/helpers.ts`
- Shared helpers: `commons-packages/backend/src/jobs/shared/`
- Job-specific helpers: `commons-packages/backend/src/jobs/helpers/`
- README: `commons-packages/backend/src/jobs/README.md`
- See [TEMPLATES.md](./TEMPLATES.md) for extended templates (cache, export, sync, workflow, bulk)
