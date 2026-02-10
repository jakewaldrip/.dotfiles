---
name: lint-running
description: Run lint and format checks in the Commons monorepo. Use when validating code style, checking for linting errors, before commits, or when the user mentions linting or formatting code.
---

# Run Lint and Format Checks

## Targets

| Target | Purpose |
|--------|---------|
| `lint:check` | ESLint code quality check |
| `format:check` | Prettier formatting check |
| `lint:fix` | ESLint auto-fix |
| `format:write` | Prettier auto-fix |

## Two Modes

### 1. Context-based (specific files)

When files are provided, lint their projects:

1. Use @nx-project-mapping to determine the Nx project for each file
2. Collect unique project names
3. Run lint on those projects:

```bash
npx nx run-many --targets "lint:check,format:check" -p <project1>,<project2>
```

**To auto-fix:**
```bash
npx nx run-many --targets "lint:fix,format:write" -p <project>
```

### 2. Git-based (changed files)

When no files specified, lint affected projects:

```bash
npx nx affected --base=$(gt parent) --targets "lint:check,format:check"
```

Uses Graphite's `gt parent` for correct base (works with stacked PRs).

## Full CI Lint Pipeline

To run lint on the entire codebase:

```bash
# Step 1: Generate builder slugs (required)
npx nx codegen @cityblock/builder

# Step 2: Run all lint checks
npx nx run-many --targets "lint:check,format:check"
```

## Examples

| File Path | Project | Command |
|-----------|---------|---------|
| `commons-packages/backend/services/member.ts` | `@commons/backend` | `npx nx run-many --targets "lint:check,format:check" -p @commons/backend` |
| `commons/app/shared/components/button.tsx` | `commons` | `npx nx run-many --targets "lint:check,format:check" -p commons` |
| Multiple projects | `a,b,c` | `npx nx run-many --targets "lint:check,format:check" -p @commons/backend,commons` |

**Note:** For packages, read the `name` field from `package.json`—directory names don't always match project names.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| EPERM errors | Run with sandbox disabled |
| Project not found | Use @nx-project-mapping; for packages, check `package.json` name field |
| Long execution | Normal for large monorepos (10+ minutes) |
