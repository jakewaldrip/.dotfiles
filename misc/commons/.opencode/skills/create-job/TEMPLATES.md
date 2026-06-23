# Job Templates Reference

Extended templates for specialized job types beyond the standard and backfill templates in SKILL.md.

## Cache/ETL Job (BigQuery streaming + chunked processing)

```typescript
import type { Request } from 'express';
import { z } from 'zod';
import logger from '@commons/backend/lib/logging.js';
import type { ScriptHandler } from '@commons/backend/jobs/helpers.js';
import { StatusError } from '@commons/backend/jobs/helpers.js';
import knex from '@commons/backend/lib/knex.js';
import { getBigQueryClient } from '@commons/backend/apis/bigquery/bigquery-client.js';
import BatchJob from '@commons/backend/models/batch-job.js';
import BatchJobRun from '@commons/backend/models/batch-job-run.js';

const TAG = 'cache-entity-name';
const BATCH_JOB_NAME = 'cache-entity-name';

const RequestBody = z.object({
  batchSize: z.number().optional().default(1000),
});

export const cacheEntityName = async (body: unknown) => {
  const bodyResult = RequestBody.safeParse(body);
  if (!bodyResult.success) {
    logger.error(bodyResult.error, { tag: TAG });
    throw new StatusError(400, 'Invalid request body');
  }

  const { batchSize } = bodyResult.data;
  const bq = getBigQueryClient();

  // Track sub-runs manually when job has multiple phases
  const batchJob = await BatchJob.findOrCreateByName(BATCH_JOB_NAME);
  const { id: batchJobId } = await BatchJobRun.create(batchJob.name);

  try {
    const query = `SELECT * FROM \`project.dataset.table\` WHERE condition = true`;
    const rows = await bq.getResults(query);

    // Chunked processing to avoid query length limits
    for (let i = 0; i < rows.length; i += batchSize) {
      const chunk = rows.slice(i, i + batchSize);
      logger.log(`Processing chunk ${i + 1} to ${i + chunk.length}`, TAG);

      await knex.raw(
        `INSERT INTO table_name (column1, column2)
         VALUES ${chunk.map(() => '(?, ?)').join(', ')}
         ON CONFLICT (column1) DO UPDATE SET column2 = EXCLUDED.column2`,
        chunk.flatMap((row) => [row.column1, row.column2]),
      );
    }

    await BatchJobRun.complete(batchJobId, true);
    logger.log(`Cached ${rows.length} records`, TAG);
    return { totalCached: rows.length };
  } catch (error: any) {
    await BatchJobRun.complete(batchJobId, false);
    logger.error(error, { tag: TAG });
    throw error;
  }
};

const main: ScriptHandler = async (req) => cacheEntityName(req.body);
export default main;
```

### Cache Job with Async Iterable Streaming

For large datasets, use BigQuery streaming with async iterables:

```typescript
import { chunkAsyncIterable } from '@commons/shared/helpers/async-helpers.js';

// Stream results instead of loading all into memory
const signalsToBeCached = await bq.streamResults<RowType>({ query });

for await (const chunk of chunkAsyncIterable(signalsToBeCached, chunkSize)) {
  // Clear DataLoader cache between chunks to prevent OOM
  loaders.entityByKey.clearAll();
  for (const row of chunk) {
    // ... process each row
  }
}
```

## Export Job (GCS upload + Datadog tracking)

```typescript
import type { Request } from 'express';
import { z } from 'zod';
import logger from '@commons/backend/lib/logging.js';
import type { ScriptHandler } from '@commons/backend/jobs/helpers.js';
import { StatusError } from '@commons/backend/jobs/helpers.js';
import BatchJobRun from '@commons/backend/models/batch-job-run.js';
import { uploadResultsToGCS } from '@commons/backend/jobs/shared/helpers.js';
import { trackEvent } from '@commons/backend/lib/datadog.js';

const TAG = 'export-entity-name';

const RequestBody = z.object({
  name: z.string(),
  patientIds: z.array(z.string()).optional(),
});

export interface ExportResults {
  successCount: number;
  failureCount: number;
  failedIds: string[];
}

async function processExport(args: z.infer<typeof RequestBody>): Promise<ExportResults> {
  const results: ExportResults = { successCount: 0, failureCount: 0, failedIds: [] };

  const patients = args.patientIds
    ? await Patient.query().findByIds(args.patientIds)
    : await Patient.query().where('status', 'active');

  // Per-patient try/catch — failures don't abort the whole job
  for (const patient of patients) {
    try {
      // ... generate export for patient ...
      results.successCount++;
    } catch (e) {
      results.failureCount++;
      results.failedIds.push(patient.id);
      logger.error(e as Error, { tag: TAG, patientId: patient.id });
      continue; // Keep processing remaining patients
    }
  }

  return results;
}

const main: ScriptHandler = async (req) => {
  const bodyResult = RequestBody.safeParse(req.body);
  if (!bodyResult.success) {
    logger.error(bodyResult.error, { tag: TAG });
    throw new StatusError(400, 'Invalid request body');
  }

  const { id: batchJobRunId } = await BatchJobRun.create(bodyResult.data.name);

  try {
    const results = await processExport(bodyResult.data);

    // Upload results to GCS if needed
    // const gcsResult = await uploadResultsToGCS({ ... });

    await BatchJobRun.complete(batchJobRunId, true);

    await trackEvent({
      tags: [`job:${TAG}`],
      text: `Export complete: ${results.successCount} succeeded, ${results.failureCount} failed`,
      title: `${TAG} complete`,
    });

    return results;
  } catch (e) {
    await BatchJobRun.complete(batchJobRunId, false);
    throw e;
  }
};

export default main;
```

## Bulk Operation Job

```typescript
import type { Request } from 'express';
import { z } from 'zod';
import logger from '@commons/backend/lib/logging.js';
import type { ScriptHandler } from '@commons/backend/jobs/helpers.js';
import { StatusError } from '@commons/backend/jobs/helpers.js';

const TAG = 'bulk-entity-operation';
const MAX_IDS = 500;

const RequestBody = z.object({
  entityIds: z.array(z.string()).min(1, 'At least one ID required').max(MAX_IDS, `Max ${MAX_IDS} IDs`),
  operatedByUserId: z.string().min(1, 'operatedByUserId is required'),
});

export const bulkEntityOperation = async (body: unknown) => {
  const bodyResult = RequestBody.safeParse(body);
  if (!bodyResult.success) {
    logger.error(bodyResult.error, { tag: TAG });
    throw new StatusError(400, 'Invalid request body');
  }

  const { entityIds, operatedByUserId } = bodyResult.data;
  let failedCount = 0;

  // Process in chunks to avoid overloading the database
  const chunkSize = 50;
  for (let i = 0; i < entityIds.length; i += chunkSize) {
    const chunk = entityIds.slice(i, i + chunkSize);
    try {
      await Entity.query()
        .patch({ status: 'updated', updatedById: operatedByUserId })
        .whereIn('id', chunk);
    } catch (error) {
      failedCount += chunk.length;
      logger.error(error as Error, { tag: TAG, chunk });
    }
  }

  return {
    requestedCount: entityIds.length,
    succeededCount: entityIds.length - failedCount,
    failedCount,
  };
};

const main: ScriptHandler = async (req) => bulkEntityOperation(req.body);
export default main;
```

## Sync Job (multi-mode with discriminated union)

```typescript
import type { Request } from 'express';
import { z } from 'zod';
import logger from '@commons/backend/lib/logging.js';
import type { ScriptHandler } from '@commons/backend/jobs/helpers.js';

const TAG = 'sync-entity-name';

// Discriminated union for multi-mode jobs
const RequestBody = z.discriminatedUnion('mode', [
  z.object({ mode: z.literal('preview') }),
  z.object({ mode: z.literal('apply-all') }),
  z.object({
    mode: z.literal('apply-single'),
    entityId: z.string(),
  }),
]);

export const suggestMappings = async () => {
  // ... find items that need syncing ...
  return { suggestions: [] };
};

export const applyAllMappings = async () => {
  // ... apply all pending syncs ...
  return { applied: 0 };
};

export const applySingle = async (entityId: string) => {
  // ... apply single sync ...
  return { applied: true };
};

const syncEntityName = async (req?: Request) => {
  const parsedBody = req?.body ? RequestBody.parse(req.body) : { mode: 'preview' as const };
  const { mode } = parsedBody;

  logger.log(`Starting sync in ${mode} mode`, TAG);

  try {
    switch (mode) {
      case 'preview':
        return { mode, ...(await suggestMappings()) };
      case 'apply-all':
        return { mode, ...(await applyAllMappings()) };
      case 'apply-single':
        return { mode, ...(await applySingle(parsedBody.entityId)) };
    }
  } catch (error: any) {
    logger.error(error, { tag: TAG, mode });
    throw error;
  }
};

export default syncEntityName;
```

## Workflow-Starting Job

```typescript
import type { Request } from 'express';
import { z } from 'zod';
import logger from '@commons/backend/lib/logging.js';
import type { ScriptHandler } from '@commons/backend/jobs/helpers.js';
import { StatusError } from '@commons/backend/jobs/helpers.js';
import knex from '@commons/backend/lib/knex.js';
import { transaction } from 'objection';
import Workflow from '@commons/backend/models/workflow.js';
import { startWorkflow } from '@commons/backend/services/workflow/start-workflow.js';

const TAG = 'start-entity-workflows';

const RequestBody = z.object({
  marketSlug: z.string().optional(),
  isDryRun: z.boolean().optional().default(false),
});

export const startEntityWorkflows = async (body: unknown) => {
  const bodyResult = RequestBody.safeParse(body);
  if (!bodyResult.success) {
    logger.error(bodyResult.error, { tag: TAG });
    throw new StatusError(400, 'Invalid request body');
  }

  const { marketSlug, isDryRun } = bodyResult.data;
  let workflowCount = 0;

  const eligiblePatients = await getEligiblePatients(marketSlug);
  logger.log(`Found ${eligiblePatients.length} eligible patients`, TAG);

  for (const patient of eligiblePatients) {
    // Per-patient transaction wrapping
    await transaction(knex, async (txn) => {
      try {
        // Idempotency: check for existing workflows before creating
        const existingWorkflows = await Workflow.query(txn)
          .where('patientId', patient.id)
          .where('templateSlug', 'workflow-slug')
          .whereIn('status', ['open', 'inProgress']);

        if (existingWorkflows.length > 0) {
          logger.log(`Skipping patient ${patient.id} — workflow already exists`, TAG);
          return;
        }

        if (!isDryRun) {
          await startWorkflow(
            {
              patientId: patient.id,
              workflowSlug: 'workflow-slug',
              homeMarketId: patient.homeMarketId,
              triggerType: 'job',
            },
            txn,
          );
        }

        workflowCount++;
      } catch (error) {
        // Log but don't abort the loop
        logger.error(error as Error, { tag: TAG, patientId: patient.id });
      }
    });
  }

  return { isDryRun, eligiblePatients: eligiblePatients.length, workflowsCreated: workflowCount };
};

const main: ScriptHandler = async (req) => startEntityWorkflows(req.body);
export default main;
```

## Common Patterns

### Environment Guard

For jobs that should only run in specific environments:

```typescript
import { envConfig } from '@commons/backend/lib/env-config.js';

const isProduction = envConfig.DEPLOYMENT === 'production';

const main: ScriptHandler = async (req) => {
  if (!isProduction) {
    void logger.warn('This job should only be run in production', TAG, {
      env: envConfig.DEPLOYMENT,
    });
    return;
  }
  // ... job logic ...
};
```

### Scoped Logger

Newer pattern that avoids passing TAG to every call:

```typescript
const taggedLogger = logger.createScopedLogger({ tag: TAG });

taggedLogger.log('Starting job');
taggedLogger.error(error, { patientId });
taggedLogger.warn('Skipping invalid record', { recordId });
```

### Attribution User

For jobs that create records on behalf of the system:

```typescript
import User from '@commons/backend/models/user.js';

const attributionUser = await User.findOrCreateAttributionUser();
await Entity.create({ ...data, createdById: attributionUser.id });
```

### Transaction Wrapping

```typescript
import { transaction } from 'objection';
import knex from '@commons/backend/lib/knex.js';

// Option 1: Objection transaction (preferred for model operations)
await transaction(knex, async (txn) => {
  await Model.query(txn).insert({ ... });
  await OtherModel.query(txn).patch({ ... });
});

// Option 2: Knex transaction (for raw queries)
await knex.transaction(async (txn) => {
  await txn.raw('INSERT INTO ...');
  await txn('table').update({ ... });
});
```

### Idempotent Upserts

```typescript
await knex.raw(
  `INSERT INTO table_name (id, column1, column2)
   VALUES ${rows.map(() => '(?, ?, ?)').join(', ')}
   ON CONFLICT (id) DO UPDATE SET
     column1 = EXCLUDED.column1,
     column2 = EXCLUDED.column2`,
  rows.flatMap((row) => [row.id, row.column1, row.column2]),
);
```

### Parallel Processing with Concurrency Limit

```typescript
import { asyncMap } from '@commons/shared/helpers/async-helpers.js';

const results = await asyncMap(
  items,
  async (item) => {
    // ... process item ...
    return result;
  },
  25, // concurrency limit
);
```

## Reference Examples

Well-structured jobs to reference when building new ones:

| Category | Example File | Notable Pattern |
|----------|-------------|-----------------|
| Backfill with dry-run | `backfill-label-definitions.ts` | Zod body, named export, batched while-loop |
| Cache from BigQuery | `cache-member-signal.ts` | Async iterable streaming, per-signal BatchJobRun |
| Export to GCS | `export-assessments-daily-tufts.ts` | Per-patient try/catch, Datadog event tracking |
| Bulk delete | `bulk-task-delete.ts` | StatusError validation, chunked deletes |
| Sync multi-mode | `sync-axle-clinician-mappings.ts` | Discriminated union schema, named exports |
| Start workflows | `start-alliance-nc-discharge-workflows.ts` | Per-patient transaction, idempotency check |
| Simple backfill | `backfill-patient-statuses.ts` | Minimal, no body params, direct model queries |
| Cache with chunks | `cache-zip-codes.ts` | External API fetch, ON CONFLICT DO NOTHING |
