---
name: github-cli
description: Reference for using the GitHub CLI (gh) to work with pull requests, issues, workflow runs, releases, and the GitHub API from a non-interactive terminal
---

# GitHub CLI (`gh`) Skill

Use `gh` for all GitHub operations: pull requests, issues, CI checks, releases, and direct API calls.

## Important Rules

- **Non-interactive only.** Never use interactive flags or prompts. Always pass all required values via flags (`--title`, `--body`, etc.).
- **Use `--json` + `--jq`** when you need to extract specific fields from output. This gives machine-parseable results.
- **Use HEREDOCs** for multi-line body content (issue bodies, PR comments, etc.):
  ```bash
  gh issue create --title "Title" --body "$(cat <<'EOF'
  ## Summary
  Multi-line body here.
  EOF
  )"
  ```
- **`-R OWNER/REPO`** targets a different repository. By default `gh` operates on the repo in the current directory.
- **`gh api`** covers anything not available through built-in commands.
- **Never use `--web` or `-w`** in automated contexts -- these open a browser and are only useful for humans.

## Pull Requests (`gh pr`)

> **Do NOT use `gh pr create`.** Pull requests are created through other tooling (e.g., Graphite CLI). Use `gh pr` subcommands only for viewing, inspecting, reviewing, merging, and managing existing PRs.

| Command | Synopsis |
|---------|----------|
| `gh pr view [<number>\|<url>\|<branch>]` | View PR details. Use `--json <fields> --jq <expr>` for structured output |
| `gh pr list` | List PRs. Filter with `--state`, `--label`, `--author`, `--assignee`, `--base`, `--head`, `--search`, `--draft`, `--limit` |
| `gh pr checks [<number>]` | Show CI status. Use `--watch` to poll, `--required` for required checks only. Exit code 8 = pending |
| `gh pr diff [<number>]` | View the diff of a PR |
| `gh pr edit <number>` | Edit PR metadata: `--title`, `--body`, `--base`, `--add-label`, `--remove-label`, `--add-reviewer`, `--add-assignee` |
| `gh pr merge [<number>]` | Merge a PR. Flags: `--squash`, `--rebase`, `--merge`, `--auto`, `--delete-branch` |
| `gh pr close [<number>]` | Close a PR without merging. Use `--delete-branch` to clean up |
| `gh pr review [<number>]` | Submit a review: `--approve`, `--request-changes`, `--comment`, `--body` |
| `gh pr ready [<number>]` | Mark a draft PR as ready for review |
| `gh pr comment [<number>]` | Add a comment: `--body` |
| `gh pr checkout [<number>]` | Check out a PR branch locally |
| `gh pr update-branch [<number>]` | Update PR branch with base branch changes. Use `--rebase` for rebase strategy |

### Key `gh pr view` JSON Fields

`number`, `title`, `body`, `state`, `url`, `author`, `assignees`, `labels`, `baseRefName`, `headRefName`, `isDraft`, `reviewDecision`, `statusCheckRollup`, `mergeStateStatus`, `mergeable`, `additions`, `deletions`, `changedFiles`, `comments`, `reviews`, `commits`, `files`, `createdAt`, `updatedAt`, `closedAt`, `mergedAt`, `mergedBy`

### Key `gh pr list` JSON Fields

`number`, `title`, `state`, `url`, `author`, `baseRefName`, `headRefName`, `isDraft`, `labels`, `reviewDecision`, `createdAt`, `updatedAt`

## Issues (`gh issue`)

| Command | Synopsis |
|---------|----------|
| `gh issue create` | Create an issue. Key flags: `--title`, `--body`, `--label`, `--assignee`, `--milestone`, `--project` |
| `gh issue list` | List issues. Filter with `--state`, `--label`, `--assignee`, `--author`, `--milestone`, `--search`, `--limit` |
| `gh issue view <number>` | View issue details. Use `--json` + `--jq` for structured output |
| `gh issue close <number>` | Close an issue. Use `--reason` (`completed`, `not_planned`) |
| `gh issue comment <number>` | Add a comment: `--body` |
| `gh issue edit <number>` | Edit issue: `--title`, `--body`, `--add-label`, `--remove-label`, `--add-assignee` |
| `gh issue develop <number>` | Create a branch linked to the issue |

### Key `gh issue list` JSON Fields

`number`, `title`, `state`, `url`, `author`, `assignees`, `labels`, `milestone`, `body`, `comments`, `createdAt`, `updatedAt`, `closedAt`

## Workflow Runs (`gh run`)

| Command | Synopsis |
|---------|----------|
| `gh run list` | List recent runs. Filter with `--workflow`, `--branch`, `--status`, `--limit` |
| `gh run view <run-id>` | View run summary. Use `--verbose` for step details, `--log` for full logs, `--log-failed` for failed step logs |
| `gh run view --job <job-id>` | View a specific job within a run |
| `gh run watch <run-id>` | Watch a run until it completes. Use `--exit-status` to exit non-zero on failure |
| `gh run rerun <run-id>` | Rerun a workflow. Use `--failed` to rerun only failed jobs |
| `gh run cancel <run-id>` | Cancel a running workflow |

### Key `gh run view` JSON Fields

`databaseId`, `displayTitle`, `name`, `status`, `conclusion`, `event`, `headBranch`, `headSha`, `url`, `jobs`, `createdAt`, `updatedAt`, `attempt`, `workflowName`

## Releases (`gh release`)

| Command | Synopsis |
|---------|----------|
| `gh release create <tag>` | Create a release. Flags: `--title`, `--notes`, `--notes-file`, `--draft`, `--prerelease`, `--generate-notes`, `--target` |
| `gh release list` | List releases. Use `--limit` |
| `gh release view <tag>` | View release details |
| `gh release edit <tag>` | Edit a release: `--title`, `--notes`, `--draft`, `--prerelease` |
| `gh release delete <tag>` | Delete a release. Use `--yes` to skip confirmation |
| `gh release download <tag>` | Download release assets |
| `gh release upload <tag> <files>` | Upload assets to an existing release |

## Repository (`gh repo`)

| Command | Synopsis |
|---------|----------|
| `gh repo view` | View repo info. Use `--json` for structured output |
| `gh repo clone <repo>` | Clone a repository |
| `gh repo create <name>` | Create a new repo. Flags: `--public`, `--private`, `--description`, `--clone` |
| `gh repo edit` | Edit repo settings: `--description`, `--default-branch`, `--visibility` |
| `gh repo sync` | Sync a fork with upstream |

## GitHub API (`gh api`)

Direct REST and GraphQL access with automatic authentication.

### REST API

```
gh api <endpoint> [flags]
```

- Placeholders `{owner}`, `{repo}`, `{branch}` are auto-filled from the current repo
- `-X METHOD` sets the HTTP method (default GET, POST if parameters present)
- `-f key=value` adds a string parameter
- `-F key=value` adds a typed parameter (booleans, ints, file reads with `@`)
- `--jq <expr>` filters JSON output
- `--paginate` fetches all pages
- `-H 'key:value'` sets custom headers

### GraphQL API

```
gh api graphql -f query='...' [-F var=value]
```

- Use `-F` for GraphQL variables
- Use `--paginate` with `$endCursor` variable and `pageInfo { hasNextPage, endCursor }` for pagination

## Search (`gh search`)

| Command | Synopsis |
|---------|----------|
| `gh search code <query>` | Search code across repos |
| `gh search issues <query>` | Search issues. Filter with `--repo`, `--state`, `--label` |
| `gh search prs <query>` | Search pull requests. Filter with `--repo`, `--state`, `--label` |
| `gh search commits <query>` | Search commits |
| `gh search repos <query>` | Search repositories. Filter with `--language`, `--topic` |

## Additional Resources

For detailed, copy-paste-ready examples organized by workflow scenario, read `EXAMPLES.md` in this skill directory.
