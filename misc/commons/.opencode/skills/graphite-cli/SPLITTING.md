# Splitting one commit into a file-grouped stack

Use this when a single branch (one commit, many files) must become a stack of focused,
independently-reviewable PRs grouped by concern (e.g. backend foundation → provider UI →
CDI UI).

## Recipe

1. **Backup first.** Preserve the original commit as a safety net:
   ```bash
   git branch backup/<linear-id>-presplit   # at the current SHA
   ```

2. **Reset to the MERGE-BASE, not to `main`.** This is the #1 landmine.
   ```bash
   BASE=$(git merge-base main HEAD)
   git reset --soft "$BASE" && git restore --staged .
   ```
   ⚠ `git reset --soft main` is WRONG when `main` has advanced past your branch point: it
   pulls main's own newer changes into your working tree as phantom "modifications". You will
   see files you never touched and the file count will not match
   `git diff --name-only main...HEAD` (three-dot, merge-base diff). Resetting to
   `git merge-base main HEAD` leaves the tree holding ONLY your changes.

3. **Build each branch by staging its file group.** The bottom group stays on the current
   (already-named) branch; each subsequent group gets a new `gt create`:
   ```bash
   # Bottom PR — commit onto the current branch
   git add <group-1 files>
   git commit --no-verify -m "[<LINEAR-ID>] <bottom scope>"

   # Next PR — stage its files, then create stacked branch (no --all: only staged files)
   git add <group-2 files>
   gt create <initials>/<LINEAR-ID>/<desc-2> --no-verify -m "[<LINEAR-ID>] <scope 2>"

   # ...repeat per group
   ```
   `--no-verify` avoids pre-commit hooks (codegen/restack) firing mid-split; run validation
   explicitly afterward.

4. **Verify integrity — the cumulative diff must equal the original.**
   ```bash
   git diff <stack-tip-branch> backup/<linear-id>-presplit --stat   # must be EMPTY
   git diff --name-only <stack-tip-branch> backup/<linear-id>-presplit   # must be EMPTY
   ```
   Empty output proves no thread was dropped or duplicated across the split.

5. **Restack onto current main.** Resetting to the merge-base leaves a "needs restack" state:
   ```bash
   gt restack
   ```
   Re-verify your files still match after restack (compare against the backup, scoped to your
   changed file list).

6. **Validate each PR ON ITS OWN BASE — not just the stack tip.** This is the key correctness
   gate for a split: a PR that only compiles when stacked on a lower PR is a CI failure waiting
   to happen. For any branch that introduces new generated-type usage (`.graphql` → codegen):
   ```bash
   gt checkout <branch>
   pnpm codegen            # if the branch adds/changes GraphQL the types depend on
   npx nx run "<project>:lint:tsc:check"
   ```
   At minimum validate the bottom branch independently, plus any branch that first references a
   newly-generated type. (Resolve `<project>` and exact targets via the `nx-project-for-file`
   tool.)

7. **Submit the stack as drafts:**
   ```bash
   gt submit --stack --draft --no-edit --no-interactive
   ```

## Reusing an existing PR as the stack bottom

Do NOT `gt rename --force` to "repurpose" the existing PR — that **detaches** the PR and
`gt submit` creates a fresh one, orphaning the original (see SKILL.md "The force-rename trap").
Instead, keep the original branch name as the bottom branch so its PR stays attached, and split
the upper work onto new branches above it. If you must rename, tell the user up front that the
old PR will be closed/superseded.
