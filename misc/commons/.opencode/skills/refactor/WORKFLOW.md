# Refactor Workflow

## Phase 1: Understand

### 1.1 Analyze the System

- Review all provided files to understand how they work together
- Identify key components, responsibilities, and relationships
- Note existing documentation or conventions

### 1.2 Draft Documentation

Create a README explaining:

- Purpose and scope
- Architecture (with Mermaid diagrams: ER for data, flowchart for processes, class for services)
- Key concepts/domain terms
- Entry points and main workflows

Write the README at its intended final location. After writing, display Mermaid diagrams in chat so user can see them rendered.

### 1.3 Confirm Understanding

Present draft to user and wait for confirmation before proceeding.

---

## Phase 2: Plan and Execute Moves

### 2.1 Propose File Organization

**Principles:**

- Files define cohesive components (React component, DB model, service, etc.)
- Tests live in `__tests__/` folders and **must move with their implementation files**
- Systems with multiple related components get their own subfolder
- Group by feature/domain, not by type
- Create clean public API in a file matching the folder name

### 2.2 Present Moves

Format each move as:

```
Move X of N: [filename]
From: [from-path]
To: [to-path]
Reason: [brief explanation]
```

Provide instructions for user to perform moves via Cursor:

1. Open file → `Cmd+Shift+P` → "Reveal Active File in Explorer View"
2. **For rename/move within folder:** Press Enter on file, type new path, press Enter
3. **For move to different folder:** `Cmd+X` to cut, navigate to destination, `Cmd+V` to paste
4. When prompted "Update imports?", select **"Always"**
5. Wait for changes to complete before proceeding

After all moves, user should run `git status` and confirm completion.

---

## Phase 3: Validate Moves

### 3.1 Check Files Moved

- Verify destination files exist with correct content
- Sample files that imported moved files to verify import paths updated

### 3.2 Fix Issues

Common problems:

- Missing import updates → grep for old paths, update manually
- Corrupted imports → fix malformed import statements
- Dynamic imports/require() → update manually
- Non-TS imports (CSS, images) → update manually
- Barrel exports (index.ts) → update exports

### 3.3 Run TypeScript Check

```bash
pnpm typecheck
```

Note: Can take 10+ minutes in large monorepos.

### 3.4 Run Tests

Use @run-tests skill for moved test files. Fix any import-related failures.

### 3.5 Iterate

Repeat 3.2-3.4 until typecheck passes and tests are green.

---

## Phase 4: Finalize

### 4.1 Update Documentation

- Move/update README to appropriate location
- Update file paths in documentation
- Ensure Mermaid diagrams reflect final structure

### 4.2 Clean Up

- Remove orphaned files from old locations
- Remove unused imports or dead code

### 4.3 Summarize Quality Concerns

Review refactored code and report:

**Test Coverage:**

- Complex logic without unit tests
- Error handling paths not covered
- Edge cases not tested

**Deprecations:**

- Deprecated patterns that should be migrated
- ESLint warnings to address
- TODO/FIXME comments

**Complexity:**

- High cyclomatic complexity (nested conditionals)
- Duplicated logic that could be extracted
- Functions violating single responsibility

---

## Error Recovery

If refactor needs to be abandoned:

1. Run `git checkout .` to revert all changes
2. Inform user what went wrong

## Notes

- This command does NOT commit changes—user reviews and commits when ready
- For very large refactors (>20 files), break into smaller batches
- Respect Nx project boundaries
