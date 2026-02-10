---
name: database-migration
description: Create database migrations from templates in the Commons monorepo. Use when the user wants to create a migration, add database columns, create tables, or modify the database schema.
---

# Create Database Migration

## When to Use

Schema changes only: adding/removing/modifying columns, tables, indexes, or feature flags.

## When NOT to Use

**Patient data operations** (backfilling, updating, transforming data) → Use `commons-packages/backend/jobs/` instead.

## Create a Migration

```bash
npm run migrate:make <name-of-migration>
```

Creates file in `commons-packages/backend/models/migrations/YYYYMMDDHHMMSS_name-of-migration.ts`

## Common Patterns

### Standard Table Columns

```typescript
table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
table.timestamp('createdAt').defaultTo(knex.raw('now()')).notNullable();
table.timestamp('updatedAt').defaultTo(knex.raw('now()')).notNullable();
```

### Soft Delete Columns

```typescript
table.timestamp('deletedAt');
table.uuid('deletedById').references('id').inTable('user').onDelete('SET NULL').nullable();
table.index(['deletedById'], `${TABLE_NAME}_deleted_by_id_idx`);
```

### Audit Columns

```typescript
table.uuid('createdById').references('id').inTable('user').onDelete('SET NULL').nullable();
table.uuid('updatedById').references('id').inTable('user').onDelete('SET NULL').nullable();
```

### Foreign Key with Index

```typescript
table.uuid('patientId').references('id').inTable('patient').onDelete('CASCADE').notNullable();
table.index(['patientId'], `${TABLE_NAME}_patient_id_idx`);
```

### Partial Index (for soft-deleted tables)

```typescript
table.index(['columnName'], `${TABLE_NAME}_column_name_idx`, {
  predicate: knex.whereNull('deletedAt'),
});
```

### Enum Column (type-safe)

```typescript
// Import TYPE only, hardcode values to prevent future breakage
import type { MyStatus } from '@commons/shared/graphql/enums/my-status.enum';

const VALUES = ['open', 'closed'] as const satisfies readonly MyStatus[];
table.enum('status', VALUES).notNullable();
```

## Validation

```bash
# Run pending migrations
npm run migrate

# Test rollback
npm run migrate:rollback
```

## Best Practices

- **Always implement both `up` and `down`** for rollback capability
- **Check table existence** before operations: `await knex.schema.hasTable(TABLE_NAME)`
- **Add indexes for foreign keys** to improve query performance
- **Use CASCADE DELETE carefully**—consider orphaned records in rollback
- **For column removal**: Rename to `drop_*` first, then drop in a later migration

## Templates and Examples

- Templates: `commons-packages/backend/models/migrations/examples/`
- See [TEMPLATES.md](./TEMPLATES.md) for additional patterns and helper functions
