# GitHub CLI Examples

Copy-paste-ready examples organized by workflow scenario.

---

## Pull Requests

> **Do NOT use `gh pr create`.** Pull requests are created through other tooling. Use these commands for viewing, inspecting, reviewing, merging, and managing existing PRs.

### Viewing & Inspecting PRs

```bash
# View the PR for the current branch
gh pr view

# View a specific PR by number
gh pr view 42

# Get the PR URL for the current branch
gh pr view --json url --jq '.url'

# Get PR status, review decision, and merge state
gh pr view 42 --json state,reviewDecision,mergeStateStatus

# List all open PRs
gh pr list

# List PRs by a specific author
gh pr list --author "@me"

# List merged PRs with a specific label
gh pr list --state merged --label "bug" --limit 10

# Get PR numbers and titles as JSON
gh pr list --json number,title --jq '.[] | "\(.number)\t\(.title)"'

# Find a PR by head branch name
gh pr list --head "feature/dark-mode" --json number,url --jq '.[0]'

# View PR diff
gh pr diff 42

# List PR files changed as JSON
gh pr view 42 --json files --jq '.files[].path'
```

### PR Checks & CI

```bash
# View checks for current branch PR
gh pr checks

# View checks for a specific PR
gh pr checks 42

# Show only required checks
gh pr checks 42 --required

# Wait for checks to complete (polls every 10s)
gh pr checks 42 --watch

# Get check status as JSON
gh pr checks 42 --json name,state,bucket --jq '.[] | select(.bucket == "fail")'

# View the workflow run that failed
gh run view <run-id> --log-failed
```

### Merging & Closing PRs

```bash
# Squash merge and delete branch
gh pr merge 42 --squash --delete-branch

# Rebase merge
gh pr merge 42 --rebase --delete-branch

# Enable auto-merge (merges when checks pass)
gh pr merge 42 --auto --squash

# Close without merging
gh pr close 42

# Close and delete the branch
gh pr close 42 --delete-branch
```

### PR Reviews & Comments

```bash
# Approve a PR
gh pr review 42 --approve --body "Looks good!"

# Request changes
gh pr review 42 --request-changes --body "Please fix the error handling in auth.ts"

# Leave a review comment
gh pr review 42 --comment --body "A few suggestions inline."

# Add a comment to a PR
gh pr comment 42 --body "CI is green, ready to merge."

# Read PR comments via API
gh api repos/{owner}/{repo}/pulls/42/comments --jq '.[] | "\(.user.login): \(.body)"'

# Read PR review comments
gh api repos/{owner}/{repo}/pulls/42/reviews --jq '.[] | "\(.user.login) (\(.state)): \(.body)"'
```

---

## Issues

### Creating Issues

```bash
# Simple issue
gh issue create --title "Bug: Login fails on Safari" --body "Steps to reproduce: ..."

# Issue with labels and assignee
gh issue create --title "Add dark mode support" --label "feature,ui" --assignee "@me"

# Issue with multi-line body
gh issue create --title "Refactor database layer" --body "$(cat <<'EOF'
## Problem
The current DB layer mixes queries and business logic.

## Proposal
- Extract repository pattern
- Add connection pooling
- Add query logging in dev mode
EOF
)"
```

### Listing & Viewing Issues

```bash
# List open issues
gh issue list

# List issues assigned to me
gh issue list --assignee "@me"

# List bugs with high priority label
gh issue list --label "bug" --label "priority:high"

# Search issues
gh issue list --search "error no:assignee sort:created-asc"

# List all issues (open + closed)
gh issue list --state all --limit 100

# View a specific issue
gh issue view 15

# Get issue details as JSON
gh issue view 15 --json title,body,labels,assignees

# Get issue URLs for a label
gh issue list --label "bug" --json number,url --jq '.[] | "\(.number): \(.url)"'
```

### Managing Issues

```bash
# Close an issue as completed
gh issue close 15 --reason completed

# Close as not planned
gh issue close 15 --reason not_planned

# Add a comment
gh issue comment 15 --body "Fixed in PR #42"

# Edit an issue
gh issue edit 15 --add-label "in-progress" --add-assignee monalisa
```

> **Tip:** To auto-close an issue when a PR merges, include `Fixes #15` or `Closes #15` in the PR body (however the PR is created).

---

## Workflow Runs

### Listing Runs

```bash
# List recent runs
gh run list

# List runs for a specific workflow
gh run list --workflow ci.yml

# List runs for current branch
gh run list --branch "$(git branch --show-current)"

# List failed runs
gh run list --status failure --limit 5

# Get run IDs and statuses as JSON
gh run list --json databaseId,displayTitle,status,conclusion --limit 10
```

### Viewing Run Details

```bash
# View a specific run
gh run view 12345

# View with step details
gh run view 12345 --verbose

# View full log for a run
gh run view 12345 --log

# View only failed step logs
gh run view 12345 --log-failed

# View a specific job
gh run view --job 456789

# View full log for a specific job
gh run view --log --job 456789

# Get run details as JSON
gh run view 12345 --json status,conclusion,jobs

# Check exit status (non-zero if failed)
gh run view 12345 --exit-status
```

### Rerunning & Watching

```bash
# Rerun all jobs
gh run rerun 12345

# Rerun only failed jobs
gh run rerun 12345 --failed

# Watch a run until completion
gh run watch 12345

# Cancel a run
gh run cancel 12345
```

---

## Releases

```bash
# Create a release with auto-generated notes
gh release create v1.2.0 --generate-notes

# Create with a title and custom notes
gh release create v1.2.0 --title "v1.2.0" --notes "Bug fixes and performance improvements."

# Create a draft prerelease
gh release create v2.0.0-beta.1 --draft --prerelease --generate-notes

# Create a release targeting a specific commit
gh release create v1.2.1 --target fix-branch --generate-notes

# Upload assets to an existing release
gh release upload v1.2.0 ./dist/app-linux-amd64 ./dist/app-darwin-amd64

# List releases
gh release list --limit 5

# View a release
gh release view v1.2.0

# Delete a release (skip confirmation)
gh release delete v1.2.0 --yes

# Download release assets
gh release download v1.2.0 --dir ./downloads
```

---

## Using `gh api`

### REST API

```bash
# List releases in the current repo
gh api repos/{owner}/{repo}/releases --jq '.[].tag_name'

# Get a specific issue
gh api repos/{owner}/{repo}/issues/42

# Post an issue comment
gh api repos/{owner}/{repo}/issues/42/comments -f body='Automated comment from CI'

# Create a label
gh api repos/{owner}/{repo}/labels -f name='urgent' -f color='ff0000' -f description='Urgent issues'

# Get PR review comments
gh api repos/{owner}/{repo}/pulls/42/comments --jq '.[] | {user: .user.login, body: .body}'

# Get commit status checks
gh api repos/{owner}/{repo}/commits/{branch}/status

# Search with query parameters
gh api -X GET search/issues -f q='repo:owner/repo is:open label:bug'

# Paginate through all results
gh api repos/{owner}/{repo}/issues --paginate --jq '.[].title'

# Set custom headers
gh api repos/{owner}/{repo}/readme -H 'Accept: application/vnd.github.v3.raw'
```

### GraphQL API

```bash
# Get repository info
gh api graphql -f query='
  query {
    repository(owner: "{owner}", name: "{repo}") {
      description
      stargazerCount
      defaultBranchRef { name }
    }
  }
'

# List PRs with variables
gh api graphql -F owner='{owner}' -F name='{repo}' -f query='
  query($owner: String!, $name: String!) {
    repository(owner: $owner, name: $name) {
      pullRequests(last: 5, states: OPEN) {
        nodes {
          number
          title
          author { login }
        }
      }
    }
  }
'

# Paginated query (all repos for current user)
gh api graphql --paginate -f query='
  query($endCursor: String) {
    viewer {
      repositories(first: 100, after: $endCursor) {
        nodes { nameWithOwner }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }
'
```

---

## Search

```bash
# Search code in a specific repo
gh search code "handleAuth" --repo owner/repo

# Search open issues across repos
gh search issues "memory leak" --state open --limit 20

# Search PRs by label
gh search prs "is:open label:bug" --repo owner/repo

# Search repos by language and topic
gh search repos "cli tool" --language go --topic cli

# Search commits by author
gh search commits "fix auth" --author monalisa --repo owner/repo
```
