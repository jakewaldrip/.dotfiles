---
name: react-component-writing
description: React component style guide
---

# React components

## Guidelines

- Export a named variable `export const ExampleComponent`. Avoid default exports.
- Avoid spread props `{...props}` in GraphQL wrapper components. List all the props individually to improve type safety and linting.
- Format the component function as a plain arrow function. Do not type with `React.FC`.

## UI components

For components that do not use GraphQL queries, writing UI components is straightforward. See example [example-ui-component.tsx](mdc:commons/app/shared/example-ui-component/example-ui-component.tsx).

## GraphQL components

For components that use GraphQL queries, component structure is separated into two components: the UI sub-component `ExampleComponentUI` and the GraphQL wrapper component, `ExampleComponent`. See example [example-graphql-component.tsx](mdc:commons/app/shared/example-graphql-component/example-graphql-component.tsx).

### Jest tests with GraphQL components

Jest tests for GraphQL components can be written in two ways:

1. Test the UI sub-component, set props directly. See [example-graphql-component-ui.spec.tsx](mdc:commons/app/shared/example-graphql-component/__tests__/example-graphql-component-ui.spec.tsx)
2. Add GraphQL mocks. See [example-graphql-component-mocks.spec.tsx](mdc:commons/app/shared/example-graphql-component/__tests__/example-graphql-component-mocks.spec.tsx)

## Internationalization

Most components use `MessageFormat` type to render internationalization text.

To render `MessageFormat` to a string, use `useFormatMessage` from Commonplace, as it is properly typed for `MessageFormat`. Do not use `useIntl` from `react-intl`.

```tsx
import { Text, useFormatMessage } from '$commons/app/shared/commonplace';

const Component = ({ pageNumber }: { pageNumber: number }) => {
  const formatMessage = useFormatMessage();
  const nextText = formatMessage({ id: 'shared.next' });
  return <Text text={`${nextText}: ${pageNumber}`} />;
};
```
