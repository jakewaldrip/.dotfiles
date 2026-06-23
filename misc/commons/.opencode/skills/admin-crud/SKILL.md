---
name: Admin CRUD UI
description: Build administrative CRUD interfaces in the Commons admin panel following established patterns for list, create, and edit views.
---

# Admin CRUD UI Skill

Build admin interfaces for managing domain entities (markets, clinics, pods, partners, etc.) in the Commons admin panel.

## Principles

1. **No destructive operations** — Never implement hard deletes. Use soft deletes (`deletedAt` column) if deletion is needed. Never allow slug changes after entity creation.
2. **Ask user for scope first** — Before writing code, confirm which CRUD operations are needed (list, create, edit) and which fields to include.
3. **Check for existing code** — Always search for existing models, resolvers, GraphQL types, and frontend components before creating new ones. Many entities already have partial implementations.
4. **Follow sentence case** — UI text uses sentence case (capitalize only first word and proper nouns). Example: "Add market" not "Add Market".
5. **Use Zod with safeParse** — All form validation uses Zod schemas with `safeParse` for type-safe validation.

## Workflow

See [WORKFLOW.md](./WORKFLOW.md) for the step-by-step process to build a new admin CRUD interface.

## Code templates

See [TEMPLATES.md](./TEMPLATES.md) for copy-paste-ready templates for each file type.

## File structure

Each admin entity requires these files. Choose **route-based** (separate pages for create/edit) or **modal-based** (inline modals on list page) depending on form complexity.

### Frontend — modal-based (preferred for simple/moderate forms)

```
commons-packages/frontend/admin-container/<entity>/
├── <entity>-manager.tsx           # List view (TableV2) + search/sort/delete
├── <entity>-modal.tsx             # Modal wrapper for create (and optionally edit)
├── <entity>-form-validation.ts    # Zod validation schema
└── graphql/
    ├── get-<entities>.graphql     # List query
    ├── get-<entity>.graphql       # Single entity query (if editing)
    ├── create-<entity>-mutation.graphql
    ├── edit-<entity>-mutation.graphql    # (if editing)
    └── delete-<entity>-mutation.graphql  # (if deleting)
```

For complex create/edit with many fields, split the form into a separate `<entity>-form.tsx` component that the modal wraps.

### Frontend — route-based (for complex forms)

```
commons-packages/frontend/admin-container/<entity>/
├── <entity>-manager.tsx           # List view (TableV2)
├── <entity>-form.tsx              # Create/edit form (shared component)
├── <entity>-view.tsx              # Edit wrapper (fetches data, passes to form)
├── <entity>-form-validation.ts    # Zod validation schema
└── graphql/
    ├── get-<entities>.graphql     # List query
    ├── get-<entity>.graphql       # Single entity query
    ├── create-<entity>-mutation.graphql
    ├── edit-<entity>-mutation.graphql
    └── delete-<entity>-mutation.graphql  # (if deleting)
```

### Backend

```
commons-packages/backend/graphql/domain/<entity>/
├── <entity>.ts                    # @ObjectType class
├── inputs/
│   ├── <entity>-create.input.ts   # @InputType for creation
│   └── <entity>-edit.input.ts     # @InputType for editing
└── resolvers/
    └── <entity>.resolver.ts       # Queries + mutations with @Authorization
```

### Routing and navigation

- **Routes**: `commons-packages/frontend/admin-container/admin-container.tsx`
- **Sidebar items**: Same file, in the `Sidebar` `sections` array

## Reference implementations

| Entity                         | Location                                              | Pattern     | Complexity | Notes                                                              |
| ------------------------------ | ----------------------------------------------------- | ----------- | ---------- | ------------------------------------------------------------------ |
| Athena insurance pkg mappings  | `admin-container/athena-insurance-package-mapping/`   | Modal       | Simple     | **Best modal starting point.** Create + delete, search, sorting.   |
| Task queues                    | `admin-container/task-queue/`                         | Modal       | Medium     | Modal with create + edit, search, sorting, protected items.        |
| Regular check-in cadences      | `admin-container/regular-check-in-cadences/`          | Route-based | Simple     | **Best route-based starting point.** Clean TableV2, no sorting.    |
| Appointment type criteria      | `admin-container/appointment-type-criteria/`          | Route-based | Simple     | TableV2 with edit + delete actions in table cells.                 |
| Clinics                        | `admin-container/clinics/`                            | Route-based | Medium     | TableV2 with column sorting + filter panel.                        |
| Pods                           | `admin-container/pods/`                               | Route-based | Medium     | Data enrichment from related entities.                             |
| Markets                        | `admin-container/markets/`                            | Route-based | Simple     | **Exception.** Legacy `List`/`ListItem` — do not use for new work. |

**Default to TableV2** for all new entities. For modal-based UIs, use `athena-insurance-package-mapping` as the starting reference. For route-based UIs, use `regular-check-in-cadences`. The `List`/`ListItem` pattern (markets) is legacy and should not be used for new admin views.

## Key imports

### Frontend (Commonplace components)

```typescript
import {
  Banner,
  Button,
  Card,
  FormLayout,
  Input,
  Layout,
  Link,
  Modal,
  Row,
  Search,
  SingleSelect,
  Spinner,
  TableV2,
  Text,
  useToasts,
} from '@commons/frontend/shared/commonplace';
```

### Backend (type-graphql)

```typescript
import { Arg, Ctx, ID, Mutation, Query, Resolver } from '@cityblock/type-graphql';
import { Field, InputType, ObjectType } from '@cityblock/type-graphql';
import { Authorization } from '@commons/backend/graphql/custom-decorators/authorization';
import { ActionType } from '@commons/shared/permissions/action-type.enum';
import { SubjectType } from '@commons/shared/permissions/subject-type.enum';
```
