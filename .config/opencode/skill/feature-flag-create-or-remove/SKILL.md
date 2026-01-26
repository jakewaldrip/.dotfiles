---
name: feature-flag
description: Create or remove feature flags in the Commons application. Use when the user wants to add a new feature flag, delete a feature flag, or asks about feature flag naming conventions.
---

# Feature Flags

## Adding a Feature Flag

1. **Add to enum** in `commons-packages/shared/graphql/enums/feature-flags.enum.ts`:
   ```typescript
   export enum FeatureFlags {
     // ... existing flags (alphabetically sorted)
     myNewFeatureFlag = 'myNewFeatureFlag',
   }
   ```

2. **Create migration** using `npm run migrate:make add-feature-flag-my-new-feature`:
   ```typescript
   import type { Knex } from 'knex';
   import {
     createFeatureFlagWithDescriptionAndTeam,
     rollbackCreateFeatureFlag,
   } from '@commons/backend/models/migrations/helpers/feature-flag-helpers';

   const FEATURE_FLAG_NAME = 'myNewFeatureFlag'; // Use string literal, NOT enum

   export async function up(knex: Knex): Promise<number[]> {
     return createFeatureFlagWithDescriptionAndTeam(
       FEATURE_FLAG_NAME,
       knex,
       'Brief description of what this flag controls',
       'Team Name', // e.g., 'Care Delivery', 'Platform', 'Growth'
     );
   }

   export async function down(knex: Knex): Promise<number> {
     return rollbackCreateFeatureFlag(FEATURE_FLAG_NAME, knex);
   }
   ```

3. **Ask user for team name** to associate with the flag.

## Removing a Feature Flag

1. **Create migration** using `npm run migrate:make remove-feature-flag-my-feature`:
   ```typescript
   import type { Knex } from 'knex';
   import {
     markFeatureFlagDeleted,
     rollbackMarkFeatureFlagDeleted,
   } from '@commons/backend/models/migrations/helpers/feature-flag-helpers';

   const FEATURE_FLAG_NAME = 'myFeatureFlag'; // Use string literal, NOT enum

   export async function up(knex: Knex): Promise<any> {
     await markFeatureFlagDeleted(FEATURE_FLAG_NAME, knex);
   }

   export async function down(knex: Knex): Promise<any> {
     await rollbackMarkFeatureFlagDeleted(FEATURE_FLAG_NAME, knex);
   }
   ```

2. **Remove from enum** in `commons-packages/shared/graphql/enums/feature-flags.enum.ts`

## Naming Conventions

- **camelCase** for flag names (e.g., `carePlanImprovements`, `gcAiTextAgent`)
- Descriptive and specific to the feature
- Avoid generic names like `newFeature` or `enableThing`

## Important

- In migrations, **always use string literals**, not enum values—the enum may change before the migration runs in all environments.
- Flags are **disabled by default**; they must be enabled per-market in the database.
- Template files: `commons-packages/backend/models/migrations/examples/_feature-flag-*.ts`
