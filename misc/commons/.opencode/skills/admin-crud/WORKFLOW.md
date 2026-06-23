# Admin CRUD UI — Workflow

Step-by-step instructions for building an admin CRUD interface for a new entity.

## Step 1: Scope discovery

Before writing any code, clarify with the user:

- **Entity name** — What is the entity? (e.g., "insurance plan", "care team")
- **CRUD operations** — Which operations? List, create, edit, delete, or a subset?
- **Fields** — What fields does the entity have? Which are required vs optional?
- **UI pattern** — Modal-based (create/edit in modals on the list page) or route-based (separate pages for create/edit)? Default to modal-based for simple/moderate forms.
- **Delete** — Should users be able to delete items? Are there protected items that shouldn't be deletable (e.g., system-managed records)?
- **List view complexity** — Basic TableV2 (default) or TableV2 with sorting/filtering/search?
- **Feature flag** — Should this be gated behind a feature flag, or use the existing `marketAdminToolUI` flag?
- **Relationships** — Does this entity relate to other entities (markets, clinics, etc.) that need to be displayed or selected?

## Step 2: Check existing code

Search for existing implementations before creating anything new:

```
# Check for existing backend model
Glob: commons-packages/backend/models/<entity>*
Glob: commons/server/models/<entity>*

# Check for existing GraphQL types
Glob: commons-packages/backend/graphql/domain/<entity>/**/*
Glob: commons/server/graphql/**/<entity>*

# Check for existing frontend components
Glob: commons-packages/frontend/admin-container/<entity>*/**/*

# Check for existing permissions
Grep: SubjectType.<Entity> in commons/shared/permissions/
```

If an existing model or GraphQL type exists, extend it rather than creating a duplicate.

## Step 3: Backend — GraphQL type and inputs

Create the backend type definition and input types. All files go in:
`commons-packages/backend/graphql/domain/<entity>/`

### 3a. Create the ObjectType

File: `<entity>.ts`

- Implements `uniqueId` interface
- Has `id`, `createdAt`, `updatedAt` fields at minimum
- Include `deletedAt` if soft deletes are supported
- See [TEMPLATES.md § ObjectType](./TEMPLATES.md#objecttype) for template

### 3b. Create input types

File: `inputs/<entity>-create.input.ts`

- All required fields are `nullable: false`
- Optional fields are `nullable: true`
- Do NOT include `id`, `createdAt`, `updatedAt`, or `deletedAt`

File: `inputs/<entity>-edit.input.ts`

- `id` field is `nullable: false` (required)
- All other fields are `nullable: true` (partial updates)
- See [TEMPLATES.md § Input types](./TEMPLATES.md#input-types) for templates

### 3c. Create the resolver

File: `resolvers/<entity>.resolver.ts`

- List query: `@Query(() => [EntityType])` — calls `Model.getAll()`
- Detail query: `@Query(() => EntityType)` — uses dataLoader or model method
- Create mutation: `@Mutation(() => EntityType)` — calls `Model.create(input)`
- Edit mutation: `@Mutation(() => EntityType)` — destructures `{ id, ...rest }` from input, calls `Model.update({ id, update: rest })`
- Every query/mutation needs `@Authorization(ActionType.xxx, SubjectType.xxx)`
- See [TEMPLATES.md § Resolver](./TEMPLATES.md#resolver) for template

### 3d. Check if SubjectType and ActionType exist

```
Grep: <Entity> in commons/shared/permissions/subject-type.enum.ts
```

If the SubjectType doesn't exist, add it. If unclear what permission to use, ask the user. Use `SubjectType.Unrestricted` for read-only queries when appropriate.

## Step 4: Frontend — GraphQL operations

Create `.graphql` files in:
`commons-packages/frontend/admin-container/<entity>/graphql/`

### Files to create

1. `get-<entities>.graphql` — List query (only fields needed for the list view)
2. `get-<entity>.graphql` — Detail query (all editable fields) — only if editing is supported
3. `create-<entity>-mutation.graphql` — Create mutation
4. `edit-<entity>-mutation.graphql` — Edit mutation (if editing)
5. `delete-<entity>-mutation.graphql` — Delete mutation (if deleting)

See [TEMPLATES.md § GraphQL operations](./TEMPLATES.md#graphql-operations) for templates.

### Run codegen

After creating `.graphql` files:

```bash
pnpm codegen
```

This generates TypeScript hooks (`useGet<Entities>Query`, `useCreate<Entity>Mutation`, etc.) and `.d.ts` type files.

## Step 5: Frontend — Components

Create components in:
`commons-packages/frontend/admin-container/<entity>/`

### 5a. Form validation

File: `<entity>-form-validation.tsx`

- Zod schema with `getFormSchema(isEditing)` — fields are optional when editing
- `validateForm(data, isEditing)` returns `{ success: true, data }` or `{ success: false, errors }`
- Uses `safeParse` (not `parse`)
- See [TEMPLATES.md § Validation](./TEMPLATES.md#validation) for template

### 5b. Form component

File: `<entity>-form.tsx`

- Shared for create and edit — accepts optional `formState` prop
- `isEditing = !isUndefined(formState)`
- Local state initialized from `formState` or `defaultFormState`
- Error state mirrors form state structure
- Submit handler validates, then calls create or edit mutation
- On success: navigate back to list, show toast
- On error: show toast with error message
- Footer with cancel + save buttons
- See [TEMPLATES.md § Form component](./TEMPLATES.md#form-component) for template

### 5c. View (edit wrapper)

File: `<entity>-view.tsx`

- Fetches entity by ID from URL params (`useParams`)
- Maps GraphQL response to form state (only fields in `defaultFormState`)
- Shows `<Spinner />` while loading
- Passes `formState` to form component
- See [TEMPLATES.md § View component](./TEMPLATES.md#view-component) for template

### 5d. Manager (list view)

File: `<entity>-manager.tsx`

**Standard pattern — TableV2** (default for all new entities):

- Uses `TableV2` with `createColumnHelper` from `@tanstack/react-table`
- Extract a separate `<Entity>Table` component that receives data as props
- Column definitions with accessors and custom cell renderers
- Add button goes in `<Layout actions={...}>` (link to create route) or `primarySlotActions` on TableV2
- Reference: `regular-check-in-cadences/regular-check-in-cadence-manager.tsx` (simple) or `clinics/clinic-manager.tsx` (with sorting)

**TableV2 with sorting/filtering** (add when needed):

- Add `SortingState` from `@tanstack/react-table` and `orderBy` from lodash
- Pass `sorting` and `onSortingChange` to TableV2
- Add `useMemo` for filtered/sorted data
- Optional: filter panel + filter chips (see clinics for reference)

**Legacy list pattern** (do not use for new entities):

- `List`/`ListItem` pattern exists only in `markets/` — treat it as an exception, not a reference
- See [TEMPLATES.md § Manager component](./TEMPLATES.md#manager-component) for all templates

## Step 6: Wire up routes

Edit `commons-packages/frontend/admin-container/admin-container.tsx`:

### 6a. Add imports

```typescript
import { <Entity>Form } from '@commons/frontend/admin-container/<entity>/<entity>-form';
import { <Entity>Manager } from '@commons/frontend/admin-container/<entity>/<entity>-manager';
import { <Entity>Edit } from '@commons/frontend/admin-container/<entity>/<entity>-view';
```

### 6b. Add sidebar item

Add to the appropriate section in the `Sidebar` `sections` array. Follow the existing pattern for feature-flag-gated items:

```typescript
hasManagerAdminToolAccess
  ? {
      text: { id: 'admin.<entities>' },
      href: `/admin/<entities>`,
      icon: '<icon>',
    }
  : null,
```

### 6c. Add routes

Add inside the `<Routes>` block:

```tsx
<Route path="<entities>" element={<<Entity>Manager />} />
<Route path="<entities>/create" element={<<Entity>Form />} />
<Route path="<entities>/:id" element={<<Entity>Edit />} />
```

### 6d. Add i18n key

Check if the i18n key (e.g., `admin.<entities>`) exists. If not, add it to the relevant locale files. Search for existing admin keys:

```
Grep: admin.markets in commons/app/ --glob "*.json"
```

## Step 7: Verification

Run these checks to confirm everything is wired up correctly:

```bash
# Generate TypeScript types from GraphQL schema
pnpm codegen

# Check TypeScript types compile
pnpm typecheck

# Lint check
pnpm lint
```

Fix any errors before considering the task complete. These commands can take 10+ minutes — use background execution or watch mode where available.
