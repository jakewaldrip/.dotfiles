---
name: test-running
description: Run automated unit and integration tests
---

## What I do

- Run automated tests

## When to use me

Use this when you need to have context around running and interpretting tests

## NEVER
- Run ALL tests, limit yourself to running specific test files intentionally

## Context

- We are using Jest in a typescript backend. We often use a test postgres database when possible to test the integrations of our data with the application code.
- We write tests for models, resolvers, and services
- When interacting with packages (especially cityblock/* packages), we tend to mock them
- We write React Testing Library tests for our react components

## Steps

### Step 1: Identify Spec Files

Look at the files that you need to run the tests for. Identify any files that are test files (files with `.spec.ts`, `.spec.tsx`, `.test.ts`, or `.test.tsx` extensions).

### Step 2: Map Files to Nx Projects

For each spec file, determine the correct nx project name based on its path using this mapping:

| File Path Pattern                     | Nx Project Name             |
| ------------------------------------- | --------------------------- |
| `commons/...`                         | `commons`                   |
| `commons-packages/backend/...`        | `@commons/backend`          |
| `commons-packages/shared/...`         | `@commons/shared`           |
| `commons-packages/commonplace/...`    | `@cityblock/commonplace`    |
| `packages/<package-name>/...`         | `@cityblock/<package-name>` |
| `cloud_functions/<function-name>/...` | `<function-name>`           |

Extract `<package-name>` or `<function-name>` from the path (the directory immediately after `packages/` or `cloud_functions/`).

### Step 3: Determine Test Target

Choose the correct nx target based on the file path:

- If the file path contains `/local/` (e.g., `__tests__/local/`), use `test-local:jest:run`
- Otherwise, use `test:jest:run`

This is important because `test:jest:run` excludes `/local/` directories by default.

### Step 4: Generate Commands

For each spec file, construct the test command using this format:

```bash
npx nx <target> <project> -- --runTestsByPath <relative-path>
```

Where:
- `<target>` is either `test:jest:run` or `test-local:jest:run` based on Step 3
- `<project>` is the nx project name from the mapping above
- `<relative-path>` is the path to the spec file **relative to the project root** (see table below)

If multiple spec files are from the same project and same target, pass multiple paths:

```bash
npx nx <target> <project> -- --runTestsByPath <relative-path1> <relative-path2>
```

#### Console Output Options

By default, console output from tests (`console.log`, `console.error`, etc.) is captured and only displayed when a test fails. This keeps test output clean and focused on failures.

To see **live console output** during test execution (useful for debugging or monitoring test progress), prefix the command with `COMMONS_TESTING_LOG_LEVEL=live`:

```bash
COMMONS_TESTING_LOG_LEVEL=live npx nx <target> <project> -- --runTestsByPath <relative-path>
```

**Available log levels:**

- `error` (default): Only show console output when tests fail
- `warn`: Show warnings and errors
- `info`: Show info, warnings, and errors
- `live`: Show all console output immediately as it happens

## Examples

### Example 1: Backend Spec File

Given context file: `commons-packages/backend/__tests__/services/member-service.spec.ts`

- Project: `@commons/backend`
- Project root: `commons-packages/backend/`
- Relative path: `__tests__/services/member-service.spec.ts`

Output:
```bash
npx nx test:jest:run @commons/backend -- --runTestsByPath __tests__/services/member-service.spec.ts
```

### Example 2: Athena Package Spec File (in /local/ directory)

Given context file: `packages/athena/__tests__/local/insurance-workflow.spec.ts`

Note: This file is in a `/local/` directory, so use `test-local:jest:run`.

- Project: `@cityblock/athena`
- Project root: `packages/athena/`
- Relative path: `__tests__/local/insurance-workflow.spec.ts`

Output:
```bash
npx nx test-local:jest:run @cityblock/athena -- --runTestsByPath __tests__/local/insurance-workflow.spec.ts
```

### Example 3: Commons App Spec File

Given context file: `commons/app/shared/components/__tests__/button.spec.tsx`

- Project: `commons`
- Project root: `commons/`
- Relative path: `app/shared/components/__tests__/button.spec.tsx`

Output:
```bash
npx nx test:jest:run commons -- --runTestsByPath app/shared/components/__tests__/button.spec.tsx
```

### Example 4: Cloud Function Spec File

Given context file: `cloud_functions/process-ciox-pdf/src/__tests__/handler.spec.ts`

- Project: `process-ciox-pdf`
- Project root: `cloud_functions/process-ciox-pdf/`
- Relative path: `src/__tests__/handler.spec.ts`

Output:
```bash
npx nx test:jest:run process-ciox-pdf -- --runTestsByPath src/__tests__/handler.spec.ts

```

### Example 5: Multiple Files from Same Project

Given context files:
- `commons-packages/backend/__tests__/services/member-service.spec.ts`
- `commons-packages/backend/__tests__/services/care-plan-service.spec.ts`

- Project: `@commons/backend`
- Project root: `commons-packages/backend/`
- Relative paths: `__tests__/services/member-service.spec.ts`, `__tests__/services/care-plan-service.spec.ts`

Output:
```bash
npx nx test:jest:run @commons/backend -- --runTestsByPath __tests__/services/member-service.spec.ts __tests__/services/care-plan-service.spec.ts
```

### Example 6: Running Tests with Live Console Output

Given context file: `commons-packages/backend/services/__tests__/regular-check-in.service.spec.ts`

When you need to see all console output during test execution (for debugging):

- Project: `@commons/backend`
- Project root: `commons-packages/backend/`
- Relative path: `services/__tests__/regular-check-in.service.spec.ts`

Output:

```bash
COMMONS_TESTING_LOG_LEVEL=live npx nx test:jest:run @commons/backend -- --runTestsByPath services/__tests__/regular-check-in.service.spec.ts
```

This will show all `console.log`, `console.error`, and other console output immediately as the tests run, rather than only on failure.
