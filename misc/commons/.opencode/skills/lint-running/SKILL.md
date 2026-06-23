---
name: lint-running
description: Advanced lint/format modes in the Commons monorepo — git-affected linting across a stack, auto-fix, and the full-CI lint pipeline. For routine "lint this file's project" resolution, call the nx-project-for-file tool instead.
---

# Advanced Lint and Format Modes

> **Project + command resolution:** Call the `nx-project-for-file` tool with the file
> path. It returns the owning project and the exact
> `npx nx run-many --targets "lint:check,format:check" -p <project>` command for the
> single-file/single-project case. This skill covers only the modes the tool does
> **not** emit.

## Targets

| Target | Purpose |
|--------|---------|
| `lint:check` | ESLint code quality check |
| `format:check` | Prettier formatting check |
| `lint:fix` | ESLint auto-fix |
| `format:write` | Prettier auto-fix |

## Auto-fix (specific projects)

```bash
npx nx run-many --targets "lint:fix,format:write" -p <project1>,<project2>
```

## Git-based (changed files across a stack)

When no specific files are given, lint affected projects using Graphite's parent as
the base (correct for stacked PRs):

```bash
npx nx affected --base=$(gt parent) --targets "lint:check,format:check"
```

## Full CI lint pipeline (entire codebase)

```bash
# Step 1: Generate builder slugs (required)
npx nx codegen @cityblock/builder

# Step 2: Run all lint checks
npx nx run-many --targets "lint:check,format:check"
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| EPERM errors | Run with sandbox disabled |
| Project not found | Call the `nx-project-for-file` tool to resolve the correct project name |
| Long execution | Normal for large monorepos (10+ minutes) |
