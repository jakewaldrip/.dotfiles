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

| File Path Pattern | Nx Project Name |
|-------------------|-----------------|
| `commons/...` | `commons` |
| `commons-packages/backend/...` | `@commons/backend` |
| `commons-packages/shared/...` | `@commons/shared` |
| `commons-packages/commonplace/...` | `@cityblock/commonplace` |
| `packages/<package-name>/...` | `@cityblock/<package-name>` |
| `cloud_functions/<function-name>/...` | `<function-name>` |

Extract `<package-name>` or `<function-name>` from the path (the directory immediately after `packages/` or `cloud_functions/`).

### Step 3: Determine Test Target

Choose the correct nx target based on the file path:

- If the file path contains `/local/` (e.g., `__tests__/local/`), use `test-local:jest:run`
- Otherwise, use `test:jest:run`

This is important because `test:jest:run` excludes `/local/` directories by default.

### Step 4: Generate Commands

For each spec file, construct the test command using this format:

```bash
npx nx <target> <project> -- --reporters=default --runTestsByPath <full-path>
```

Where:
- `--reporters=default` shows standard Jest output instead of the silent reporter used in CI
- `<target>` is either `test:jest:run` or `test-local:jest:run` based on Step 3
- `<project>` is the nx project name from the mapping above
- `<full-path>` is the full path to the spec file (e.g., `packages/athena/__tests__/local/insurance-workflow.spec.ts`)

If multiple spec files are from the same project and same target, pass multiple paths:

```bash
npx nx <target> <project> -- --reporters=default --runTestsByPath <path1> <path2>
```

## Examples

### Example 1: Backend Spec File

Given context file: `commons-packages/backend/__tests__/services/member-service.spec.ts`

Output:
```bash
npx nx test:jest:run @commons/backend -- --reporters=default --runTestsByPath commons-packages/backend/__tests__/services/member-service.spec.ts
```

### Example 2: Athena Package Spec File (in /local/ directory)

Given context file: `packages/athena/__tests__/local/insurance-workflow.spec.ts`

Note: This file is in a `/local/` directory, so use `test-local:jest:run`.

Output:
```bash
npx nx test-local:jest:run @cityblock/athena -- --reporters=default --runTestsByPath packages/athena/__tests__/local/insurance-workflow.spec.ts
```

### Example 3: Commons App Spec File

Given context file: `commons/app/shared/components/__tests__/button.spec.tsx`

Output:
```bash
npx nx test:jest:run commons -- --reporters=default --runTestsByPath commons/app/shared/components/__tests__/button.spec.tsx
```

### Example 4: Cloud Function Spec File

Given context file: `cloud_functions/process-ciox-pdf/src/__tests__/handler.spec.ts`

Output:
```bash
npx nx test:jest:run process-ciox-pdf -- --reporters=default --runTestsByPath cloud_functions/process-ciox-pdf/src/__tests__/handler.spec.ts
```

### Example 5: Multiple Files from Same Project

Given context files:
- `commons-packages/backend/__tests__/services/member-service.spec.ts`
- `commons-packages/backend/__tests__/services/care-plan-service.spec.ts`

Output:
```bash
npx nx test:jest:run @commons/backend -- --reporters=default --runTestsByPath commons-packages/backend/__tests__/services/member-service.spec.ts commons-packages/backend/__tests__/services/care-plan-service.spec.ts
```
