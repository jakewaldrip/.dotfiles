# Create Model Workflow

Step-by-step guidance for creating a new database model.

## Step 1: Gather Requirements

Ask user:
- Table name
- Description of what this model represents

## Step 2: Check if Table Exists

- Use the `grep` tool to locate the table
- If no migration found, ask if user wants to create one first (use @create-migration skill).

## Step 3: Analyze Table Structure

If migration exists, read it to understand:
- Column names and types
- Foreign key relationships
- Soft-delete columns (deletedAt, deletedById)
- Audit columns (createdById, updatedById)

If no migration, ask user for column details.

## Step 4: Choose Base Class

| Requirement | Base Class |
|-------------|------------|
| Standard model | `BaseModel` |
| Patient-related + enrollment scoping | `PatientEnrollmentRelatedModel` |
| Has Draft.js content | `MarkdownModel` |
| Needs Zod validation | `ZodValidatedModel` mixin |

## Step 5: Generate Model File

Use templates from skill file
1. Field declarations with `!` operator
2. `tableName` set to database table name
3. `jsonSchema` for validation (or Zod schema)
4. Static query methods (getById, getAll, create, update, softDelete)

## Step 6: Write File

Location: `commons-packages/backend/models/{kebab-case-name}.ts`

## Step 7: Present Summary

```
Model Created!

File: commons-packages/backend/models/{model-name}.ts
Class: {ModelName}
Base Class: {BaseModel|PatientEnrollmentRelatedModel|etc.}

Features:
- [x] Standard fields (id, createdAt, updatedAt)
- [x/o] Soft-delete support
- [x/o] Audit columns
- [x/o] Zod validation

Import: import ModelName from '@commons/backend/models/model-name';

Next Steps:
- Create GraphQL types/resolvers if needed
- Consider creating test file
```

## Step 8: Offer Follow-ups

Ask if user wants:
1. **Test file** at `commons-packages/backend/models/__tests__/{model-name}.spec.ts`
2. **GraphQL types** in `commons-packages/backend/graphql/domain/{domain}/types/`

## Example Models

Reference well-structured models:
- Simple: `commons-packages/backend/models/label-definition.ts`
- Complex: `commons-packages/backend/models/task.ts`
- With Zod: `commons-packages/backend/models/goal.ts`
