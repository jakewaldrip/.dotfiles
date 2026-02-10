---
name: react-component-writing
description: React component patterns and style guide for the Commons monorepo. Use when creating React components, working with GraphQL in components, or implementing internationalization with MessageFormat.
---

# React Components

## Component Guidelines

- **Named exports only**: `export const MyComponent = ...` (no default exports)
- **Plain arrow functions**: Don't type with `React.FC`
- **No spread props in GraphQL wrappers**: List all props individually for type safety

```tsx
interface MyComponentProps {
  title: MessageFormat;
  onSubmit: () => void;
}

export const MyComponent = ({ title, onSubmit }: MyComponentProps) => {
  // ...
};
```

## UI Components (no GraphQL)

Simple structure—see example: `commons-packages/frontend/shared/example-ui-component/`

```tsx
interface ExampleUiComponentProps {
  description?: MessageFormat;
  onSubmitClick: () => void;
  title: MessageFormat;
}

export const ExampleUiComponent = ({ description, onSubmitClick, title }: ExampleUiComponentProps) => {
  // Component implementation
};
```

## GraphQL Components

Separate into two components:

1. **UI sub-component** (`MyComponentUI`): Renders UI, receives data as props
2. **GraphQL wrapper** (`MyComponent`): Fetches data, passes to UI

See example: `commons-packages/frontend/shared/example-graphql-component/`

```tsx
// UI sub-component
interface MyComponentUIProps extends MyComponentBaseProps {
  error?: ApolloError;
  isLoading?: boolean;
  data?: GetDataQuery['data'];
}

export const MyComponentUI = ({ error, isLoading, data }: MyComponentUIProps) => {
  if (isLoading) return <Spinner />;
  if (error) return <ErrorComponent error={error} />;
  return (/* render UI */);
};

// GraphQL wrapper
export const MyComponent = ({ id }: MyComponentProps) => {
  const { data, loading, error } = useGetDataQuery({ variables: { id } });

  return (
    <MyComponentUI
      isLoading={loading}
      error={error}
      data={data?.data}
    />
  );
};
```

## Custom Hooks

- Prefix with `use`: `useMyHook`
- Return typed objects or tuples
- Place in `hooks/` directory or co-locate with component

```tsx
interface UseMyHookResult {
  value: string;
  setValue: (v: string) => void;
  isLoading: boolean;
}

export const useMyHook = (initialValue: string): UseMyHookResult => {
  // ...
};
```

## Internationalization

Use `MessageFormat` for text. Render with `useFormatMessage` from Commonplace (**not** `useIntl` from react-intl):

```tsx
import { Text, useFormatMessage } from '@commons/frontend/shared/commonplace';

const Component = ({ pageNumber }: { pageNumber: number }) => {
  const formatMessage = useFormatMessage();
  const nextText = formatMessage({ id: 'shared.next' });
  return <Text text={`${nextText}: ${pageNumber}`} />;
};
```

## Testing

### Import from test-utils

```tsx
import { render } from '@commons/frontend/rtlTests/test-utils';
```

This wraps components with necessary providers (IntlProvider, MockedProvider, AppStateProvider, Router).

### Two Approaches for GraphQL Components

1. **Test UI sub-component directly** — pass props without mocks:
   ```tsx
   render(<MyComponentUI data={mockData} isLoading={false} />);
   ```

2. **Use GraphQL mocks** — test full wrapper:
   ```tsx
   render(<MyComponent id="123" />, { customMocks: [myMock] });
   ```

See examples: `commons-packages/frontend/shared/example-graphql-component/__tests__/`

## File Structure

Co-locate related files:
```
my-component/
├── my-component.tsx
├── my-component.graphql
├── my-component.css (or .module.css)
└── __tests__/
    └── my-component.spec.tsx
```
