---
name: refactor
description: Reorganize and document code with safe file moves and continuous validation. Use when refactoring file structure, reorganizing code, or documenting a system.
disable-model-invocation: true
---

# Refactor Code

Reorganize and document code systems with safe file moves and continuous validation.

## Workflow Overview

| Phase             | Steps                                                                     |
| ----------------- | ------------------------------------------------------------------------- |
| 1. Understand     | Analyze system, draft README with Mermaid diagrams, get user confirmation |
| 2. Plan & Execute | Propose file moves, user performs moves via Cursor, wait for confirmation |
| 3. Validate       | Check files moved, imports updated, fix issues, run typecheck and tests   |
| 4. Finalize       | Update docs, clean up, summarize quality concerns                         |

See [WORKFLOW.md](./WORKFLOW.md) for detailed step-by-step instructions.

## Key Principles

- **Tests move with implementation**: When moving `foo.ts`, also move `__tests__/foo.spec.ts`
- **Group by feature/domain**: Not by type (avoid separate `components/`, `services/`, `utils/` folders)
- **Co-locate tests**: Tests live in `__tests__/` folders near the code they test
- **Clean public APIs**: Folder should have an entry file with the same name (e.g., `memberSignals/memberSignals.ts`)
- **Editor-native moves**: Rely on Cursor's TypeScript language server to update imports

## Nx Considerations

This repo uses Nx—respect project boundaries:

- Don't move files across Nx project boundaries without understanding implications
- Cross-project imports must use proper package paths, not relative imports
- If moving files between projects, consider if the code should be in a shared package

## Prerequisites

- `typescript.updateImportsOnFileMove.enabled` set to `"always"` or `"prompt"` in Cursor settings
- For large refactors (>20 files), break into smaller batches
