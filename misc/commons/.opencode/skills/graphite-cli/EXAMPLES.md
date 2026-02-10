# Graphite CLI Examples

Detailed workflow examples for common scenarios.

## Basic Workflow: Create and Submit a Stack

### Creating the First PR

```bash
# Ensure you're on trunk
gt checkout main

# Make your code changes, then create branch with commit
gt create feat-add-user-api --all --message "feat(api): add user endpoint"

# Submit to GitHub (creates PR)
gt submit --no-interactive
```

### Stacking a Second PR

```bash
# You're on the first branch, make more changes
# Then create a new branch stacked on top
gt create feat-user-frontend --all --message "feat(ui): add user list component"

# Submit entire stack
gt submit --stack --no-interactive
```

### Visualize Your Stack

```bash
# See the stack structure
gt log

# Output example:
#   main
#   ├── feat-add-user-api
#   │   └── feat-user-frontend  ← you are here
```

## Updating PRs

### Amending the Current Branch

When you need to make changes to the current PR:

```bash
# Make your code changes, then amend
gt modify --all

# Push the update
gt submit --no-interactive
```

### Adding a New Commit (Instead of Amending)

```bash
# Add a separate commit for the changes
gt modify --commit --all --message "fix: handle edge case in user validation"

# Push the update
gt submit --no-interactive
```

### Updating a PR Mid-Stack

When you need to fix something in an earlier PR:

```bash
# Navigate to the branch that needs changes
gt checkout feat-add-user-api

# Make your fixes, then amend (automatically restacks descendants)
gt modify --all

# Submit the entire stack to update all PRs
gt submit --stack --no-interactive
```

## Syncing with Trunk

### Regular Sync

```bash
# Fetch latest main, rebase all branches, cleanup merged
gt sync

# If prompted about merged branches, confirm deletion
```

### Sync Without Restacking

```bash
gt sync --no-restack
```

### Force Sync (Skip Confirmations)

```bash
gt sync --force
```

## Handling Conflicts

### During Sync or Restack

```bash
# Graphite reports conflict in file.ts
# 1. Open file.ts and resolve the conflict markers
# 2. Stage the resolved file
git add file.ts

# 3. Continue the operation
gt continue

# Or abort if you want to start over
gt abort
```

### Continue with All Changes Staged

```bash
gt continue --all
```

## Stack Restructuring

### Reordering Branches

```bash
# Opens editor showing branch order
gt reorder

# In editor, reorder the lines:
# main
# feat-user-frontend    <- moved up
# feat-add-user-api     <- moved down

# Save and close - Graphite rebases automatically
```

### Moving a Branch to Different Parent

```bash
# Move current branch onto a different parent
gt move --onto main

# Or interactively select target
gt move
```

### Insert a Branch Mid-Stack

```bash
# On parent branch, create with --insert
gt checkout feat-add-user-api
gt create feat-user-validation --all --message "feat: add validation" --insert

# This inserts between feat-add-user-api and its child
```

### Folding a Branch into Its Parent

```bash
# Combine current branch with parent
gt fold

# Keep current branch name instead of parent's
gt fold --keep
```

### Splitting a Multi-Commit Branch

```bash
# Split by commit (each commit becomes a branch)
gt split --by-commit

# Split by hunk (interactive)
gt split --by-hunk
```

### Squashing Commits

```bash
# Squash all commits in branch into one
gt squash --no-edit

# Squash with new message
gt squash --message "feat: complete user feature"
```

## Smart Amendments with Absorb

When you have changes that should go into specific earlier commits:

```bash
# Stage changes
git add -A

# Absorb automatically finds the right commits
gt absorb

# Preview without applying
gt absorb --dry-run

# Apply without confirmation
gt absorb --force
```

## Navigating the Stack

```bash
# Go up one level (to child)
gt up

# Go up 2 levels
gt up 2

# Go down one level (to parent)
gt down

# Go to top of stack
gt top

# Go to bottom of stack (closest to trunk)
gt bottom

# Interactive branch picker
gt checkout
```

## Merging and Cleanup

### Merge via Graphite

```bash
# Merge all PRs from trunk to current branch
gt merge

# Preview what would be merged
gt merge --dry-run

# Confirm before merging
gt merge --confirm
```

### Post-Merge Cleanup

```bash
# Sync will prompt to delete merged branches
gt sync

# Force cleanup without prompts
gt sync --force
```

## PR Management

### Create PRs as Drafts

```bash
gt submit --draft --no-interactive
```

### Assign Reviewers

```bash
gt submit --reviewers alice,bob --no-interactive
```

### Mark as Merge When Ready

```bash
gt submit --merge-when-ready --no-interactive
```

### Open PR in Browser

```bash
# Current branch's PR
gt pr

# Specific branch's PR
gt pr feat-add-user-api

# Stack view
gt pr --stack
```

## Recovery and Undo

### Undo Last Graphite Operation

```bash
gt undo

# Force without confirmation
gt undo --force
```

### Abort Paused Operation

```bash
gt abort

# Force without confirmation
gt abort --force
```

## Agent-Specific Patterns

### Planning a Stack Before Implementation

Before writing code, plan the stack structure:

```
Stack Plan:
1. feat-database-schema - Add new tables for user preferences
2. feat-api-endpoints - Create CRUD endpoints for preferences
3. feat-ui-components - Add preferences panel to settings
4. feat-integration-tests - Add e2e tests for preferences flow

Each PR builds on the previous. Shall I proceed?
```

### Non-Interactive Batch Operations

```bash
# Create and submit in one flow
gt create feat-my-feature --all --message "feat: description"
gt submit --no-interactive --no-edit

# Create multiple stacked branches
gt create step-1 --all --message "refactor: extract helper"
gt create step-2 --all --message "feat: add new feature using helper"
gt create step-3 --all --message "test: add tests for new feature"
gt submit --stack --no-interactive --no-edit
```

### Handling Pre-commit Hook Modifications

```bash
# If pre-commit hook (e.g., prettier, eslint --fix) modifies files
# After gt create or gt modify, files may be modified by hooks

# Include hook modifications in the commit
gt modify --all
gt submit --no-interactive
```

### Checking Stack Status

```bash
# View full stack
gt log

# View just current stack context
gt log --stack

# Get branch info
gt info --diff
```

## Common Patterns Summary

| Task | Command |
| ---- | ------- |
| Start new feature | `gt create name --all -m "feat: desc"` |
| Update current PR | `gt modify --all && gt submit --no-interactive` |
| Fix earlier PR | `gt checkout branch && gt modify --all && gt submit --stack --no-interactive` |
| Stay current | `gt sync` |
| See stack | `gt log` |
| Navigate up/down | `gt up` / `gt down` |
| Submit stack | `gt submit --stack --no-interactive` |
| Resolve conflicts | Fix files, `git add`, `gt continue` |
| Undo mistake | `gt undo` |
