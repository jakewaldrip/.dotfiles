---
name: create-model
description: Create Objection.js model files with proper structure in the Commons monorepo. Use when the user wants to create a new model, add a database entity, or needs a model class for a table.
---

# Create Database Model

Create Objection.js model files following Commons patterns.

## Prerequisites

- Table must exist (or have a migration created)
- Table **must have `id`, `createdAt`, and `updatedAt` columns** (required by BaseModel)

## Base Class Selection

| Use Case | Base Class |
|----------|------------|
| Standard model | `BaseModel` |
| Patient-related with enrollment scoping | `PatientEnrollmentRelatedModel` |
| Has Draft.js content | `MarkdownModel` |
| Needs Zod validation | `ZodValidatedModel` mixin with `Mixin()` |

## Standard Model Template

```typescript
import type { JSONSchema, Transaction } from 'objection';
import BaseModel from '@commons/backend/models/base-model';

export default class ModelName extends BaseModel {
  // Fields with ! (non-null assertion)
  fieldName!: string;
  optionalField!: string | null;
  deletedAt!: string | null;
  deletedById!: string | null;
  // These audit columns are only included if applicable. They are not compulsory
  createdById!: string | null;
  updatedById!: string | null;

  static tableName = 'table_name';

  // We do NOT include a jsonSchema, it is a deprecated pattern

  static async getById(id: string, txn?: Transaction) {
    return ModelName.query(txn).findById(id).whereNull('deletedAt');
  }

  static async getAll(txn?: Transaction): Promise<ModelName[]> {
    return ModelName.query(txn).whereNull('deletedAt');
  }

  static async create(input: CreateInput, userId: string, txn?: Transaction): Promise<ModelName> {
    return ModelName.query(txn).insertAndFetch({
      ...input,
      createdById: userId,
      updatedById: userId,
    });
  }

  static async update(id: string, input: UpdateInput, userId: string, txn?: Transaction): Promise<ModelName> {
    return ModelName.query(txn).patchAndFetchById(id, {
      ...input,
      updatedById: userId,
    });
  }

  static async softDelete(id: string, userId: string, txn?: Transaction): Promise<ModelName> {
    return ModelName.query(txn).patchAndFetchById(id, {
      deletedAt: new Date().toISOString(),
      deletedById: userId,
    });
  }
}
```

## Zod Validated Model Template

```typescript
import { Mixin } from 'ts-mixer';
import { z } from 'zod';
import BaseModel from '@commons/backend/models/base-model';
import ZodValidatedModel, { DateInStringsClothing } from '@commons/backend/models/mixins/zod-validated-model';

const ModelNameColumns = z.object({
  id: z.string(),
  fieldName: z.string(),
  optionalField: z.string().nullable(),
  deletedAt: z.string().nullable(),
  deletedById: z.string().nullable(),
  createdAt: DateInStringsClothing,
  updatedAt: DateInStringsClothing,
});

export default class ModelName extends Mixin(ZodValidatedModel(ModelNameColumns), BaseModel) {
  // No additional fields are listed on Zod validated models
  // because they do not interact well with the validator
  static tableName = 'table_name';

  // Static query methods...
}
```

## Rules

1. **Use `!` for field declarations** (non-null assertion)
2. **Always include soft-delete filter** in query methods if table has `deletedAt`
3. **Include transaction parameter** in all static methods: `txn?: Transaction`
4. **Include audit tracking** in create/update if table has audit columns
5. **Do NOT add relationMappings** — query related data explicitly using data loaders, joins or separate queries
6. **Use `DateInStringsClothing`** for createdAt/updatedAt in Zod schemas

## File Location

`commons-packages/backend/models/{kebab-case-name}.ts`

Example: `LabelDefinition` → `label-definition.ts`

**Related models (2+ files):** Organize into subdirectory with barrel export and README.

## Import Path

```typescript
import ModelName from '@commons/backend/models/model-name';
```

## Reference

- BaseModel: `commons-packages/backend/models/base-model.ts`
- ZodValidatedModel: `commons-packages/backend/models/mixins/zod-validated-model.ts`
- EnrollmentModel: `commons-packages/backend/models/patient-enrollment/patient-enrollment-related.ts`
- See [WORKFLOW.md](./WORKFLOW.md) for step-by-step guidance
