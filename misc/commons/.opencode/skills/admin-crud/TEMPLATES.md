# Admin CRUD UI — Code Templates

All templates are extracted from the actual codebase. Replace `<Entity>`, `<entity>`, and `<entities>` with your entity name (e.g., `Market`, `market`, `markets`).

---

## ObjectType

File: `commons-packages/backend/graphql/domain/<entity>/<entity>.ts`

Reference: `commons-packages/backend/graphql/domain/market/market.ts`

```typescript
import { GraphQLDateTime } from 'graphql-scalars';
import { uniqueId } from '@commons/backend/graphql/shared/interface/unique-id';
import { Field, ID, ObjectType } from '@cityblock/type-graphql';

@ObjectType({ implements: uniqueId })
export class <Entity> implements uniqueId {
  @Field(() => ID)
  id!: string;

  @Field(() => String)
  name!: string;

  // Add entity-specific fields here.
  // Use { nullable: true } for optional fields:
  // @Field(() => String, { nullable: true })
  // description?: string | null;

  @Field(() => GraphQLDateTime)
  createdAt!: string;

  @Field(() => GraphQLDateTime)
  updatedAt!: string;

  @Field(() => GraphQLDateTime, { nullable: true })
  deletedAt?: string | null;
}
```

---

## Input types

### Create input

File: `commons-packages/backend/graphql/domain/<entity>/inputs/<entity>-create.input.ts`

Reference: `commons-packages/backend/graphql/domain/market/inputs/market-create.input.ts`

```typescript
import { Field, InputType } from '@cityblock/type-graphql';

@InputType()
export class <Entity>CreateInput {
  @Field(() => String, { nullable: false })
  name!: string;

  // Add required fields with { nullable: false }
  // Add optional fields with { nullable: true }
  // Do NOT include id, createdAt, updatedAt, or deletedAt
}
```

### Edit input

File: `commons-packages/backend/graphql/domain/<entity>/inputs/<entity>-edit.input.ts`

Reference: `commons-packages/backend/graphql/domain/market/inputs/market-edit.input.ts`

```typescript
import { Field, InputType } from '@cityblock/type-graphql';

@InputType()
export class <Entity>EditInput {
  @Field(() => String, { nullable: false })
  id!: string;

  @Field(() => String, { nullable: true })
  name?: string;

  // All fields except id are nullable (partial updates)
}
```

---

## Resolver

File: `commons-packages/backend/graphql/domain/<entity>/resolvers/<entity>.resolver.ts`

Reference: `commons-packages/backend/graphql/domain/market/resolvers/market.resolver.ts`

```typescript
import { ActionType } from '@commons/shared/permissions/action-type.enum';
import { SubjectType } from '@commons/shared/permissions/subject-type.enum';
import { Authorization } from '@commons/backend/graphql/custom-decorators/authorization';
import { <Entity>CreateInput } from '@commons/backend/graphql/domain/<entity>/inputs/<entity>-create.input';
import { <Entity>EditInput } from '@commons/backend/graphql/domain/<entity>/inputs/<entity>-edit.input';
import { <Entity> } from '@commons/backend/graphql/domain/<entity>/<entity>';
import { IContext } from '@commons/backend/graphql/shared/utils';
import <Entity>Model from '@commons/backend/models/<entity>';
import { Arg, Ctx, ID, Mutation, Query, Resolver } from '@cityblock/type-graphql';

@Resolver()
export class <Entity>Resolver {
  @Query(() => [<Entity>])
  @Authorization(ActionType.read, SubjectType.Unrestricted)
  async <entities>() {
    return <Entity>Model.getAll();
  }

  @Query(() => <Entity>)
  @Authorization(ActionType.read, SubjectType.Unrestricted)
  async <entity>(@Arg('<entity>Id', () => ID) <entity>Id: string, @Ctx() context: IContext) {
    const <entity> = await context.dataLoaders.<entity>.load(<entity>Id);

    if (!<entity>) {
      throw new Error(`No such <entity>: ${<entity>Id}`);
    }

    return <entity>;
  }

  @Mutation(() => <Entity>)
  @Authorization(ActionType.create, SubjectType.<Entity>)
  async <entity>Create(
    @Arg('input', () => <Entity>CreateInput) input: <Entity>CreateInput,
  ): Promise<<Entity>> {
    try {
      return await <Entity>Model.create(input);
    } catch (err) {
      return Promise.reject(err);
    }
  }

  @Mutation(() => <Entity>)
  @Authorization(ActionType.update, SubjectType.<Entity>)
  async <entity>Edit(
    @Arg('input', () => <Entity>EditInput) { id, ...rest }: <Entity>EditInput,
  ): Promise<<Entity>> {
    try {
      return await <Entity>Model.update({ id, update: rest });
    } catch (err) {
      return Promise.reject(err);
    }
  }
}
```

**Notes:**

- If a dataLoader doesn't exist for this entity, use the model directly: `await <Entity>Model.get(<entity>Id)`
- Add domain-specific error handling in catch blocks as needed (see market resolver for unique constraint examples)
- Check `SubjectType` enum — if `<Entity>` doesn't exist there, add it or ask the user

---

## GraphQL operations

### List query

File: `commons-packages/frontend/admin-container/<entity>/graphql/get-<entities>.graphql`

Reference: `commons-packages/frontend/admin-container/markets/graphql/get-markets.graphql`

```graphql
query get<Entities> {
  <entities> {
    id
    name
    # Only include fields needed for the list view
  }
}
```

### Detail query

File: `commons-packages/frontend/admin-container/<entity>/graphql/get-<entity>.graphql`

Reference: `commons-packages/frontend/admin-container/markets/graphql/get-market.graphql`

```graphql
query get<Entity>($<entity>Id: ID!) {
  <entity>(<entity>Id: $<entity>Id) {
    name
    # All editable fields (no id, createdAt, updatedAt)
  }
}
```

### Create mutation

File: `commons-packages/frontend/admin-container/<entity>/graphql/create-<entity>-mutation.graphql`

Reference: `commons-packages/frontend/admin-container/markets/graphql/create-market-mutation.graphql`

```graphql
mutation create<Entity>(
  $name: String!
  # All create fields with appropriate types and nullability
) {
  <entity>Create(
    input: {
      name: $name
      # Map all variables to input fields
    }
  ) {
    id
  }
}
```

### Edit mutation

File: `commons-packages/frontend/admin-container/<entity>/graphql/edit-<entity>-mutation.graphql`

Reference: `commons-packages/frontend/admin-container/markets/graphql/edit-market-mutation.graphql`

```graphql
mutation edit<Entity>(
  $id: String!
  $name: String
  # All edit fields — only id is required (String!), others are optional
) {
  <entity>Edit(
    input: {
      id: $id
      name: $name
      # Map all variables to input fields
    }
  ) {
    id
  }
}
```

---

## Validation

File: `commons-packages/frontend/admin-container/<entity>/<entity>-form-validation.tsx`

Reference: `commons-packages/frontend/admin-container/markets/market-form-validation.tsx`

```typescript
import { z } from 'zod';
import type { State as FormState } from '@commons/frontend/admin-container/<entity>/<entity>-form';

const getFormSchema = (isEditing: boolean) => {
  const nameVal = z.string().min(2, 'Please enter a name');
  // Define validators for each field

  return z
    .object({
      name: isEditing ? nameVal.optional() : nameVal,
      // All fields optional when editing, required when creating
    })
    .passthrough();
};

type FormSchema = z.infer<ReturnType<typeof getFormSchema>>;

export const validateForm = (
  data: FormState,
  isEditing: boolean,
):
  | { success: false; errors: { [key in keyof FormSchema]?: string } }
  | { success: true; data: FormSchema } => {
  const validation = getFormSchema(isEditing).safeParse(data);
  if (validation.success) return { success: true, data: validation.data };

  const errors: { [key in keyof FormSchema]?: string } = {};
  Object.entries(validation.error.flatten().fieldErrors).forEach(([key, value]) => {
    if (value && value.length > 0) {
      errors[key as keyof FormSchema] = value[0];
    }
  });
  return { success: false, errors };
};
```

---

## Form component

File: `commons-packages/frontend/admin-container/<entity>/<entity>-form.tsx`

Reference: `commons-packages/frontend/admin-container/markets/market-form.tsx`

```typescript
import isEmpty from 'lodash/isEmpty';
import isUndefined from 'lodash/isUndefined';
import forEach from 'lodash/forEach';
import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useCreate<Entity>Mutation } from '@commons/frontend/admin-container/<entity>/graphql/create-<entity>-mutation.graphql';
import { useEdit<Entity>Mutation } from '@commons/frontend/admin-container/<entity>/graphql/edit-<entity>-mutation.graphql';
import { validateForm } from '@commons/frontend/admin-container/<entity>/<entity>-form-validation';
import {
  Button,
  Card,
  FormLayout,
  Input,
  Layout,
  Row,
  useToasts,
} from '@commons/frontend/shared/commonplace';

export interface State {
  name: string;
  // Add all editable fields, typed as strings
}

export const default<Entity>FormState: State = {
  name: '',
  // Initialize all fields to empty string
} as const;

const defaultErrorState = Object.keys(default<Entity>FormState).reduce(
  (a, v) => ({ ...a, [v]: null }),
  {},
);

export const <Entity>Form = ({ formState }: { formState?: State }) => {
  const isEditing = !isUndefined(formState);
  const { id: <entity>Id } = useParams<{ id: string }>();
  const [create<Entity>] = useCreate<Entity>Mutation();
  const [edit<Entity>] = useEdit<Entity>Mutation();
  const [state, setState] = useState(isEditing ? formState : default<Entity>FormState);
  const [formErrors, setFormErrors] = useState<{ [key: string]: string | null | undefined }>(
    defaultErrorState,
  );
  const [isDisabled, setIsDisabled] = React.useState(true);
  const { addToast } = useToasts();
  const navigate = useNavigate();

  const updateFormField = ({
    field,
    state,
    value,
  }: {
    field: string;
    state: State;
    value: string | null;
  }) =>
    setState({
      ...state,
      [field]: value,
    });

  React.useEffect(() => {
    const areInputsFilled = Object.values(state).every(
      (v) => v != null && String(v).trim().length >= 1,
    );
    setIsDisabled(isEditing ? !hasChanges(formState, state) : !areInputsFilled);
  }, [state, formState]);

  async function handleSubmit() {
    const formValidation = validateForm(state, isEditing);
    if (formValidation.success) {
      let res: any;
      if (isEditing) {
        res = <entity>Id && (await edit<Entity>({ variables: { id: <entity>Id, ...state } }));
      } else {
        res = await create<Entity>({ variables: state });
      }

      if (res?.errors) {
        addToast({
          isError: true,
          text: { id: '<entity>.update.failure', values: { message: res.errors[0].message } },
        });
      }
      if (res?.data) {
        navigate('/admin/<entities>');
      }
    } else {
      setFormErrors(formValidation.errors);
    }
  }

  function FormFooter() {
    return (
      <Row justifyContent="end">
        <Button intent="ghost" href="/admin/<entities>" text={{ id: 'shared.cancel' }} />
        <Button
          intent="primary"
          isDisabled={isDisabled}
          onClick={handleSubmit}
          text={{ id: 'shared.save' }}
        />
      </Row>
    );
  }

  return (
    <Layout title={isEditing ? formState.name : { id: 'admin.create<Entity>' }} columnWidth="medium">
      <Card>
        <FormLayout>
          <Input
            isRequired
            {...(formErrors.name ? { errorMessage: formErrors.name } : {})}
            label={{ id: 'shared.name' }}
            onChange={({ target: { value } }) =>
              updateFormField({ state, field: 'name', value })
            }
            value={state.name}
          />
          {/* Add more fields here using Input, SingleSelect, etc. */}
          <FormFooter />
        </FormLayout>
      </Card>
    </Layout>
  );
};

function hasChanges(currForm: State, updateForm: State) {
  const diff: { [key: string]: string } = {};
  forEach(currForm, function (v, k) {
    const tK = k as keyof State;
    if (updateForm[tK] && v != updateForm[tK]) {
      diff[tK] = updateForm[tK];
    }
  });
  return !isEmpty(diff);
}
```

---

## View component

File: `commons-packages/frontend/admin-container/<entity>/<entity>-view.tsx`

Reference: `commons-packages/frontend/admin-container/markets/market-view.tsx`

```typescript
import forIn from 'lodash/forIn';
import React from 'react';
import { useParams } from 'react-router-dom';
import { useGet<Entity>Query } from '@commons/frontend/admin-container/<entity>/graphql/get-<entity>.graphql';
import {
  <Entity>Form,
  default<Entity>FormState,
} from '@commons/frontend/admin-container/<entity>/<entity>-form';
import { Spinner } from '@commons/frontend/shared/commonplace';

export const <Entity>Edit = () => {
  const { id: <entity>Id = '' } = useParams();
  const { data, loading: isLoading } = useGet<Entity>Query({
    variables: { <entity>Id },
    fetchPolicy: 'cache-and-network',
  });

  const formState: any = {};

  if (isLoading) {
    return <Spinner />;
  }

  if (data?.<entity>) {
    forIn(data.<entity>, (val, key) => {
      if (Object.keys(default<Entity>FormState).includes(key)) {
        formState[key] = val ?? '';
      }
    });

    return <<Entity>Form formState={formState} />;
  }

  return null;
};
```

---

## Manager component

### TableV2 pattern (default)

File: `commons-packages/frontend/admin-container/<entity>/<entity>-manager.tsx`

Reference: `commons-packages/frontend/admin-container/regular-check-in-cadences/regular-check-in-cadence-manager.tsx`

```typescript
import { createColumnHelper } from '@tanstack/react-table';
import React from 'react';
import type { Get<Entities>Query } from '@commons/frontend/admin-container/<entity>/graphql/get-<entities>.graphql';
import { useGet<Entities>Query } from '@commons/frontend/admin-container/<entity>/graphql/get-<entities>.graphql';
import {
  Banner,
  Button,
  Layout,
  Link,
  Spinner,
  TableV2,
  Text,
} from '@commons/frontend/shared/commonplace';

type <Entity>Row = Get<Entities>Query['<entities>'][number];

const columnHelper = createColumnHelper<<Entity>Row>();

const <Entity>Table = ({ <entities> }: { <entities>?: readonly <Entity>Row[] }) => (
  <TableV2
    columns={[
      columnHelper.accessor('name', {
        cell: (info) => info.getValue(),
        header: () => <Text text="Name" />,
      }),
      // Add more columns here
      columnHelper.accessor('id', {
        cell: (info) => (
          <Link to={`/admin/<entities>/${info.getValue()}`}>View</Link>
        ),
        header: () => null,
        enableSorting: false,
      }),
    ]}
    allRowsLength={(<entities> ?? []).length}
    data={<entities> ?? []}
    primarySlotActions={[]}
    primarySlotBulkActions={[]}
    titleText=""
    units="<entities>"
  />
);

export const <Entity>Manager = () => {
  const {
    data: all<Entities>Data,
    error: all<Entities>DataError,
    loading: is<Entity>DataLoading,
  } = useGet<Entities>Query({ fetchPolicy: 'cache-and-network' });

  return (
    <Layout
      actions={<Button icon="add" href="/admin/<entities>/create" text={{ id: 'admin.create<Entity>' }} />}
      title={{ id: 'admin.<entities>' }}
    >
      {is<Entity>DataLoading ? (
        <Spinner />
      ) : (
        <<Entity>Table <entities>={all<Entities>Data?.<entities>} />
      )}
      {all<Entities>DataError && (
        <Banner icon="error" intent="danger" text={all<Entities>DataError.message} />
      )}
    </Layout>
  );
};
```

### TableV2 pattern with sorting

Add when column sorting is needed. Reference: `commons-packages/frontend/admin-container/clinics/clinic-manager.tsx`

```typescript
import { createColumnHelper } from '@tanstack/react-table';
import type { OnChangeFn, SortingState } from '@tanstack/react-table';
import { orderBy } from 'lodash';
import React, { useMemo, useState } from 'react';
import type { Get<Entities>Query } from '@commons/frontend/admin-container/<entity>/graphql/get-<entities>.graphql';
import { useGet<Entities>Query } from '@commons/frontend/admin-container/<entity>/graphql/get-<entities>.graphql';
import {
  Banner,
  Button,
  Layout,
  Link,
  Spinner,
  TableV2,
  Text,
} from '@commons/frontend/shared/commonplace';

type <Entity>Row = Get<Entities>Query['<entities>'][number];

const columnHelper = createColumnHelper<<Entity>Row>();

const <Entity>Table = ({
  <entities>,
  sorting,
  onSortingChange,
}: {
  <entities>?: readonly <Entity>Row[];
  sorting?: SortingState;
  onSortingChange?: OnChangeFn<SortingState>;
}) => (
  <TableV2
    columns={[
      columnHelper.accessor('name', {
        cell: (info) => info.getValue(),
        header: () => <Text text="Name" />,
      }),
      columnHelper.accessor('id', {
        cell: (info) => (
          <Link to={`/admin/<entities>/${info.getValue()}`}>View</Link>
        ),
        header: () => null,
        enableSorting: false,
      }),
    ]}
    allRowsLength={(<entities> ?? []).length}
    data={<entities> ?? []}
    primarySlotActions={[]}
    primarySlotBulkActions={[]}
    titleText=""
    units="<entities>"
    sorting={sorting}
    onSortingChange={onSortingChange}
  />
);

export const <Entity>Manager = () => {
  const {
    data: all<Entities>Data,
    error: all<Entities>DataError,
    loading: is<Entity>DataLoading,
  } = useGet<Entities>Query({ fetchPolicy: 'cache-and-network' });

  const [sorting, setSorting] = useState<SortingState>([]);

  const handleSortingChange: OnChangeFn<SortingState> = (updater) => {
    const newSorting = Array.isArray(updater) ? updater : updater(sorting);
    setSorting(newSorting);
  };

  const sortedData = useMemo(() => {
    if (!all<Entities>Data?.<entities>) return [];

    if (!sorting.length) {
      return orderBy(all<Entities>Data.<entities>, [(<entity>) => <entity>.name.toLowerCase()], ['asc']);
    }

    const sort = sorting[0];
    if (sort.id === 'name') {
      return orderBy(
        all<Entities>Data.<entities>,
        [(<entity>) => <entity>.name.toLowerCase()],
        [sort.desc ? 'desc' : 'asc'],
      );
    }

    return orderBy(all<Entities>Data.<entities>, [(<entity>) => <entity>.name.toLowerCase()], ['asc']);
  }, [all<Entities>Data?.<entities>, sorting]);

  return (
    <Layout
      actions={
        <Button icon="add" href="/admin/<entities>/create" text={{ id: 'admin.create<Entity>' }} />
      }
      title={{ id: 'admin.<entities>' }}
    >
      {is<Entity>DataLoading ? (
        <Spinner />
      ) : (
        <<Entity>Table
          <entities>={sortedData}
          sorting={sorting}
          onSortingChange={handleSortingChange}
        />
      )}
      {all<Entities>DataError && (
        <Banner icon="error" intent="danger" text={all<Entities>DataError.message} />
      )}
    </Layout>
  );
};
```

### Legacy list pattern (do not use for new entities)

This pattern exists only in `markets/` and should not be used for new admin views. Reference: `commons-packages/frontend/admin-container/markets/market-manager.tsx`

```typescript
import React from 'react';
import { useGet<Entities>Query } from '@commons/frontend/admin-container/<entity>/graphql/get-<entities>.graphql';
import {
  Banner,
  Button,
  Card,
  Layout,
  List,
  ListItem,
  Spinner,
} from '@commons/frontend/shared/commonplace';
import { PageTitle } from '@commons/frontend/shared/page-title/page-title';

export const <Entity>Manager = () => {
  const {
    data: all<Entities>Data,
    error: all<Entities>DataError,
    loading: is<Entity>DataLoading,
  } = useGet<Entities>Query({ fetchPolicy: 'cache-and-network' });

  return (
    <Layout
      actions={<Button icon="add" href="/admin/<entities>/create" text={{ id: 'admin.create<Entity>' }} />}
      title={{ id: 'admin.<entities>' }}
      columnWidth="medium"
      scroll="all"
    >
      <PageTitle title="admin.<entities>" />
      {is<Entity>DataLoading ? (
        <Spinner />
      ) : (
        <Card padding="none" hasBorder={false}>
          <List>
            {all<Entities>Data?.<entities>.map((<entity>) => (
              <ListItem
                key={<entity>.id}
                primaryText={<entity>.name}
                secondaryText={/* secondary display field */}
                href={`/admin/<entities>/${<entity>.id}`}
              />
            ))}
          </List>
        </Card>
      )}
      {all<Entities>DataError && (
        <Banner icon="error" intent="danger" text={all<Entities>DataError.message} />
      )}
    </Layout>
  );
};
```
