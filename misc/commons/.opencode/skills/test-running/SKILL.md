---
name: test-running
description: Run Jest tests in the Commons monorepo. Use when testing code changes, validating implementations, debugging test failures, or when the user mentions running tests.
---

# Run Jest Tests

## Quick Reference

```bash
npx nx <target> <project> -- --runTestsByPath <relative-path>
```

| Component | How to Determine |
|-----------|-----------------|
| `<target>` | `test-local:jest:run` if path contains `/local/`, otherwise `test:jest:run` |
| `<project>` | Use @nx-project-mapping skill to get project name |
| `<relative-path>` | Path relative to **project root**, not repo root |

## Workflow

1. Use @nx-project-mapping to get the project name and root
2. Strip the project root prefix from the file path to get the relative path
3. Choose target: `test-local:jest:run` for `/local/` paths, `test:jest:run` otherwise
4. Run the command

## Examples

| File Path | Project | Relative Path | Command |
|-----------|---------|---------------|---------|
| `commons-packages/backend/__tests__/services/member.spec.ts` | `@commons/backend` | `__tests__/services/member.spec.ts` | `npx nx test:jest:run @commons/backend -- --runTestsByPath __tests__/services/member.spec.ts` |
| `packages/athena/__tests__/local/workflow.spec.ts` | `@cityblock/athena` | `__tests__/local/workflow.spec.ts` | `npx nx test-local:jest:run @cityblock/athena -- --runTestsByPath __tests__/local/workflow.spec.ts` |

## Running Multiple Files

Same project, same target—pass multiple paths:

```bash
npx nx test:jest:run @commons/backend -- --runTestsByPath __tests__/a.spec.ts __tests__/b.spec.ts
```

## Running All Tests for a Project

Omit `--runTestsByPath` to run all tests:

```bash
npx nx test:jest:run @commons/backend
```

## Console Output (Debugging)

By default, console output is captured and only shown on failure. For live output:

```bash
COMMONS_TESTING_LOG_LEVEL=live npx nx test:jest:run <project> -- --runTestsByPath <path>
```

Log levels: `error` (default) | `warn` | `info` | `live`

## Watch Mode

For development, add `--watch`:

```bash
npx nx test:jest:run @commons/backend -- --runTestsByPath __tests__/my.spec.ts --watch
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| EPERM errors | Run with sandbox disabled (permission issues with npm/node modules) |
| Test not found | Verify path is relative to project root, not repo root |
| `/local/` tests not running | Use `test-local:jest:run` target instead of `test:jest:run` |
