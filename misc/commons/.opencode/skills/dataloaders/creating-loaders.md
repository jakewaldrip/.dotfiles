# Creating a DataLoader

Follow these steps to add a new DataLoader. All new loaders use the model static method pattern and `DataLoaders.getOrCreateLoader` for request-scoped batching and caching.

## 1. Bulk fetch

Add or reuse a model (or service) method that takes a list of keys and returns a list of results (e.g. `getByIds`, `getByXxxIds`). Keep the underlying query simple (e.g. `whereIn`).

## 2. Factory

Create a private static factory that returns a DataLoader using `returnsSingleItem` or `returnsMultipleItems` from `commons-packages/backend/graphql/shared/loaders.ts`:

- **Single item per key** (e.g. user by id, patient by id): `returnsSingleItem(bulkLoad, idFn)`
- **Multiple items per key** (e.g. tasks per goal, goals per pathway): `returnsMultipleItems(bulkLoad, idFn)`

The **bulkLoad** function takes `readonly Key[]` and returns `Promise<Result[]>`.
The **id** function maps each result to the key it belongs to (e.g. `(task) => task.goalGroupId`).

## 3. Public loader accessor

Expose the loader via `DataLoaders.getOrCreateLoader` so it’s request-scoped:

```typescript
static taskByIdLoader(providedLoaders?: DataLoaders) {
  return DataLoaders.getOrCreateLoader(Task.taskByIdLoaderFactory, providedLoaders);
}
```

## 4. Usage

In resolvers or other request-scoped code: `Task.taskByIdLoader().load(id)`.

See [docs/dataloaders.md](../../../docs/dataloaders.md) and existing model loaders (e.g. `Task.taskByIdLoader`) for full examples.

---

## returnsSingleItem vs returnsMultipleItems

- **returnsSingleItem**: `loader.load(key)` returns one item or undefined (e.g. user by id, patient by id). Use when the bulk loader is keyed by the same key that uniquely identifies the result (e.g. primary key).
- **returnsMultipleItems**: `loader.load(key)` returns an array (e.g. tasks for a goal). Use when the bulk loader returns many rows per key (e.g. foreign key lookups).

## Compound keys and normalize

For compound keys (e.g. `{ patientId, typeId }`), pass an optional **normalize** function so the key used for batching/caching matches the **id** function on results. You can also pass `loaderSettings` (e.g. `maxBatchSize`). See existing loaders in `commons-packages/backend/graphql/shared/loaders.ts` for examples.
