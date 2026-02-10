# Migration Templates Reference

## NPM Scripts

- Use `npm run migrate:make {migration-name}` to create a new migration file
- Use `npm run migrate` to run pending migrations
- Use `npm run migrate:rollback` to rollback the last migration
- Use `npm run migrate:examples` to run example migrations (for testing templates)

## Migration File Structure

- Migration files are created in `commons-packages/backend/models/migrations/`
- Files follow timestamp naming: `YYYYMMDDHHMMSS_migration-name.ts`
- Template migrations are in `commons-packages/backend/models/migrations/examples/`
- Helper functions are in `commons-packages/backend/models/migrations/helpers/`

The name of the templates are representative of what they do.

## Common Patterns

### Standard Table Creation

```typescript
table.uuid('id').primary().defaultTo(knex.raw('uuid_generate_v4()'));
table.timestamp('createdAt').defaultTo(knex.raw('now()')).notNullable();
table.timestamp('updatedAt').defaultTo(knex.raw('now()')).notNullable();
table.timestamp('deletedAt'); // For soft delete
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
table.index(['createdById'], `${TABLE_NAME}_created_by_id_idx`);
table.index(['updatedById'], `${TABLE_NAME}_updated_by_id_idx`);
```

### Partial Indexes (for soft-deleted tables)

```typescript
table.index([COLUMN], `${TABLE_NAME}_column_idx`, {
  predicate: knex.whereNull('deletedAt'),
});
```

### Foreign Keys with Cascade Delete

```typescript
// Method 1: Inline
table.uuid('userId').references('id').inTable('user').onDelete('CASCADE').notNullable();

// Method 2: Separate constraint (preferred for clarity)
await knex.schema.alterTable(TABLE_NAME, (table) => {
  table
    .foreign('userId', `${TABLE_NAME}_user_id_foreign`)
    .references('id')
    .inTable('user')
    .onDelete('CASCADE');
});
```

### Enum Columns (Type-Safe Pattern)

```typescript
// Import TYPE only, hardcode values to prevent future breakage
import type { SubtaskStatus } from '@commons/shared/graphql/enums/subtask-status.enum';

const VALUES = ['open', 'complete'] as const satisfies readonly SubtaskStatus[];

table.enum('status', VALUES).notNullable();
```

## Helper Functions

Use helpers from `commons-packages/backend/models/migrations/helpers/`:

### Feature Flags

```typescript
import {
  createFeatureFlagWithDescriptionAndTeam,
  markFeatureFlagDeleted,
} from './helpers/feature-flag-helpers';

// Always include description and team
await createFeatureFlagWithDescriptionAndTeam(
  'flagName',
  knex,
  'Description with date',
  'team-email@example.com',
);
```

### Enum Constraints

```typescript
import { formatAlterTableEnumSql } from './helpers/enum-helpers';

await knex.raw(formatAlterTableEnumSql('table_name', 'column_name', ['value1', 'value2']));
```

## Migration Process

1. Run `npm run migrate:make {migration-name}` to generate the migration file
2. Copy content from appropriate template in `examples/` folder
3. Modify table names, column names, and values
4. Implement both `up` and `down` functions
5. Test in development: `npm run migrate`
6. Test rollback: `npm run migrate:rollback`
7. Apply to staging/production after code review

## Best Practices

- **Always test migrations in development** before applying to staging/production
- **Use descriptive migration names** that explain what the migration does
- **Include both `up` and `down` functions** for rollback capability
- **Use templates** from `examples/` folder for consistency
- **Check table existence** before operations: `await knex.schema.hasTable(TABLE_NAME)`
- **Use two-part pattern for column removal**: Rename to `drop_*` first, then drop later
- **Add indexes for foreign keys** to improve query performance
- **Use partial indexes** for soft-deleted tables with `predicate: knex.whereNull('deletedAt')`
- **Use CASCADE DELETE carefully** - consider orphaned records in rollback
- **For feature flags** - always include description and team/owner
- **For enum columns** - import TYPE only and hardcode values to prevent breaking changes
- **Reference existing migrations** for patterns and consistency

## Related Documentation

- See `docs/commons-playbook/migrations.md` for additional guidance
- Migration templates with examples: `commons-packages/backend/models/migrations/examples/README.md`
