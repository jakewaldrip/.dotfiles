---
name: graphql-resolver
description: Create GraphQL resolvers, output types, input types, and field resolvers in the Commons monorepo. Use when building a GraphQL API layer for a feature, adding queries/mutations, or resolving nested relations on output types.
---

# GraphQL Resolver

Create type-graphql resolvers, output types, input types, and field resolvers following Commons patterns.

## Prerequisites

- Backend models must exist (or be created first -- use `create-model` skill)
- CASL subject type must be registered in `subject-type.enum.ts`
- CASL rules must be defined in `define-ability.ts`

## File Locations

| File Type      | Location                                                                                           |
| -------------- | -------------------------------------------------------------------------------------------------- |
| Output types   | `commons-packages/backend/src/graphql/domain/{domain}/outputs/{name}.output.ts`                    |
| Input types    | `commons-packages/backend/src/graphql/domain/{domain}/inputs/{name}.input.ts`                      |
| Resolver       | `commons-packages/backend/src/graphql/domain/{domain}/resolvers/{name}.resolver.ts`                |
| Field resolver | `commons-packages/backend/src/graphql/domain/{domain}/resolvers/{name}.field.resolver.ts`          |
| Tests          | `commons-packages/backend/src/graphql/domain/{domain}/resolvers/__tests__/{name}.resolver.spec.ts` |

## Output Type Pattern

Output types declare the GraphQL schema shape. `@DataSafety` is NOT required on output types (only inputs).

```typescript
import { Field, ID, ObjectType } from '@cityblock/type-graphql';

@ObjectType()
export class MyEntityType {
  @Field(() => ID)
  id!: string;

  @Field(() => String)
  name!: string;

  @Field(() => String, { nullable: true })
  optionalField?: string | null;

  @Field(() => Date)
  createdAt!: Date;

  @Field(() => Date)
  updatedAt!: Date;

  // Relation fields -- these are populated by field resolvers, NOT by the main resolver.
  // Declare them here so the schema knows about them, but their data comes from
  // @FieldResolver methods in the field resolver class.

  @Field(() => UserType)
  user!: UserType;

  @Field(() => [MarketType])
  markets!: MarketType[];

  @Field(() => UserType, { nullable: true })
  createdBy?: UserType | null;
}
```

**Key point**: Relation fields (user, markets, etc.) are declared on the output type but populated by field resolvers. The main resolver only returns the flat model row. type-graphql automatically calls the field resolvers to fill in the rest.

## Input Type Pattern

Every field on an input type needs both `@DataSafety` and `@Field` decorators:

```typescript
import { Field, ID, InputType } from '@cityblock/type-graphql';
import { DataSafety } from '@commons/backend/graphql/shared/data-safety.js';

@InputType()
export class MyEntityCreateInput {
  @DataSafety({ phi: 'safe' })
  @Field(() => String)
  name!: string;

  @DataSafety({ phi: 'safe' })
  @Field(() => String, { nullable: true })
  optionalField?: string;
}
```

For update inputs, include `id` as required and make all other fields optional (`nullable: true`).

## Resolver Pattern

The main resolver handles queries and mutations. It returns flat model rows -- nested relations are resolved separately by field resolvers.

```typescript
import { Arg, Ctx, ID, Mutation, Query, Resolver } from '@cityblock/type-graphql';
import { Authorization } from '@commons/backend/graphql/custom-decorators/authorization.js';
import type { IContext } from '@commons/backend/graphql/shared/utils.js';
import { ActionType } from '@commons/shared/permissions/action-type.enum.js';
import { SubjectType } from '@commons/shared/permissions/subject-type.enum.js';

@Resolver()
export class MyEntityResolver {
  @Query(() => [MyEntityType])
  @Authorization(ActionType.read, SubjectType.MyEntity)
  async myEntities(): Promise<MyEntityType[]> {
    return MyEntityModel.getAll();
    // Returns flat rows -- field resolvers handle nested data
  }

  @Query(() => MyEntityType, { nullable: true })
  @Authorization(ActionType.read, SubjectType.MyEntity)
  async myEntity(@Arg('id', () => ID) id: string): Promise<MyEntityType | null> {
    return MyEntityModel.getById(id) ?? null;
  }

  @Mutation(() => MyEntityType)
  @Authorization(ActionType.create, SubjectType.MyEntity)
  async myEntityCreate(
    @Arg('input') input: MyEntityCreateInput,
    @Ctx() context: IContext,
  ): Promise<MyEntityType> {
    return MyEntityModel.create(input, context.user.id);
  }

  @Mutation(() => MyEntityType)
  @Authorization(ActionType.update, SubjectType.MyEntity)
  async myEntityUpdate(
    @Arg('input') input: MyEntityUpdateInput,
    @Ctx() context: IContext,
  ): Promise<MyEntityType> {
    const { id, ...patch } = input;
    return MyEntityModel.update(id, patch, context.user.id);
  }

  @Mutation(() => MyEntityType)
  @Authorization(ActionType.delete, SubjectType.MyEntity)
  async myEntityDeactivate(
    @Arg('id', () => ID) id: string,
    @Ctx() context: IContext,
  ): Promise<MyEntityType> {
    return MyEntityModel.softDelete(id, context.user.id);
  }
}
```

## Field Resolver Pattern (Resolving Nested Relations)

Nested relations on output types MUST be resolved via `@FieldResolver` methods using dataloaders. This avoids N+1 queries and keeps the resolver layer clean.

Create a **separate file** for field resolvers: `{name}.field.resolver.ts`

```typescript
import { Ctx, FieldResolver, Resolver, Root } from '@cityblock/type-graphql';
import type { IContext } from '@commons/backend/graphql/shared/utils.js';
import { EfficientUserModel } from '@commons/backend/models/user.js';

@Resolver(() => MyEntityType)
export class MyEntityFieldResolver {
  // Simple FK -> single entity (model-level loader, no context needed)
  @FieldResolver(() => UserType, { nullable: false })
  user(@Root() root: MyEntityType): Promise<UserType | undefined> {
    return EfficientUserModel.userByIdLoader().load(root.userId);
  }

  // Nullable FK -- return null early if no FK value
  @FieldResolver(() => UserType, { nullable: true })
  createdBy(@Root() root: MyEntityType): Promise<UserType | undefined> | null {
    return root.createdById ? EfficientUserModel.userByIdLoader().load(root.createdById) : null;
  }

  // One-to-many via context dataloader
  @FieldResolver(() => [RelatedType], { nullable: false })
  relatedItems(@Root() root: MyEntityType, @Ctx() context: IContext): Promise<RelatedModel[]> {
    return context.dataLoaders.relatedItemsForEntity.load(root.id);
  }

  // Many-to-many via join table (two-step: load join rows, then load related entities)
  @FieldResolver(() => [MarketType], { nullable: false })
  async markets(@Root() root: MyEntityType, @Ctx() context: IContext): Promise<MarketType[]> {
    const joinRows = await context.dataLoaders.entityMarkets.load(root.id);
    const markets = await context.dataLoaders.market.loadMany(joinRows.map((row) => row.marketId));
    return markets.filter((m): m is MarketModel => m instanceof MarketModel);
  }
}
```

### Creating Dataloaders

**Model-level loaders** (preferred when no request context is needed):

```typescript
// In the model file
import {
  DataLoaders,
  returnsMultipleItems,
  returnsSingleItem,
} from '@commons/backend/graphql/shared/loaders.js';

export default class MyJoinModel extends BaseModel {
  static async getByEntityIds(entityIds: readonly string[]): Promise<MyJoinModel[]> {
    return MyJoinModel.query().whereIn('entityId', entityIds);
  }

  private static loaderFactory() {
    return returnsMultipleItems(
      MyJoinModel.getByEntityIds.bind(MyJoinModel),
      (row) => row.entityId,
    );
  }

  static loader(providedLoaders?: DataLoaders) {
    return DataLoaders.getOrCreateLoader(MyJoinModel.loaderFactory, providedLoaders);
  }
}
```

**Context-level loaders** (when the loader needs request context or is widely used):

Register on the `DataLoaders` class in `commons-packages/backend/src/graphql/shared/loaders.ts`:

```typescript
export class DataLoaders {
  entityMarkets = returnsMultipleItems(
    MyJoinModel.getByEntityIds.bind(MyJoinModel),
    (row) => row.entityId,
  );
}
```

### Dataloader Helpers

| Helper                                           | Use Case                                |
| ------------------------------------------------ | --------------------------------------- |
| `returnsSingleItem(bulkLoadFn, keyExtractor)`    | FK lookups -- one result per key        |
| `returnsMultipleItems(bulkLoadFn, keyExtractor)` | One-to-many -- array of results per key |

## Permission Gating Rules

Every query and mutation MUST have an `@Authorization` decorator. Use the correct `ActionType`:

| Operation                    | ActionType          | Examples                           |
| ---------------------------- | ------------------- | ---------------------------------- |
| Query (single or list)       | `ActionType.read`   | `getEntity`, `listEntities`        |
| Create mutation              | `ActionType.create` | `entityCreate`                     |
| Edit/patch mutation          | `ActionType.update` | `entityUpdate`, `entityEdit`       |
| Archive/restore (reversible) | `ActionType.update` | `archiveEntity`, `restoreEntity`   |
| Soft-delete / deactivate     | `ActionType.delete` | `entityDeactivate`, `entityDelete` |
| Hard delete                  | `ActionType.delete` | `entityDelete`                     |
| Terminate (user/entity)      | `ActionType.delete` | `userTerminate`                    |

**The distinction**: `ActionType.update` is for reversible state changes. `ActionType.delete` is for destructive-intent operations, even if implemented as a soft delete.

Gate **every** CRUD operation individually. Do not rely on one permission covering multiple operations (e.g., do not use `update` to gate both edit and delete).

## Rules

1. **Resolve nested relations via field resolvers + dataloaders**, not via `withGraphFetched`, `joinRelated`, or Objection.js `relationMappings` in the resolver layer
2. **Keep resolvers thin** -- resolvers call model static methods; business logic lives in models or services
3. **Use `@DataSafety` on input types only** -- output types do not need it
4. **Gate every CRUD operation** with the correct `ActionType` (see table above)
5. **Avoid type casts between model and output types** -- if you find yourself needing `as OutputType` to satisfy the return type, the design likely needs field resolvers instead of manual object transformation
6. **Run `npm run codegen`** after creating or modifying types/resolvers to regenerate frontend hooks
7. **Model methods called from resolvers should return flat rows** -- no eager loading of relations in model query methods used by resolvers

## Reference

- Authorization decorator: `commons-packages/backend/src/graphql/custom-decorators/authorization.ts`
- DataLoaders class: `commons-packages/backend/src/graphql/shared/loaders.ts`
- Action types: `commons-packages/shared/src/permissions/action-type.enum.ts`
- Subject types: `commons-packages/shared/src/permissions/subject-type.enum.ts`
- IContext: `commons-packages/backend/src/graphql/shared/utils.ts`
- Example field resolver (simple): `commons-packages/backend/src/graphql/domain/care-team/resolvers/care-team.field.resolver.ts`
- Example field resolver (complex): `commons-packages/backend/src/graphql/domain/task/resolvers/task.field.resolver.ts`
- Example CRUD resolver: `commons-packages/backend/src/graphql/domain/clinical-hub/resolvers/clinical-hub.resolver.ts`
