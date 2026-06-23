# gh repo and repo data

Use `-R owner/repo` (or `GH_REPO`) for commands that support it.

## Clone

```bash
gh repo clone owner/repo [DIR]
```

## View repo

```bash
gh repo view [owner/repo]
```

- `--web` – open on GitHub  
- `--json name,description,url,...` – specific fields

## List branches

```bash
gh api repos/{owner}/{repo}/branches
```

With pagination and names only:

```bash
gh api repos/{owner}/{repo}/branches --paginate --jq '.[].name'
```

Or from a local clone: `git branch -r` (remote branches).

## List commits

```bash
gh api repos/{owner}/{repo}/commits --jq '.[].sha'
```

With branch and options:

```bash
gh api "repos/{owner}/{repo}/commits?sha=main&per_page=30"
```

Parameters: `sha` (branch/tag/SHA), `per_page`, `page`, `author`, `since` (ISO 8601).

## Get one commit

```bash
gh api repos/{owner}/{repo}/commits/<SHA>
```

With diff:

```bash
gh api repos/{owner}/{repo}/commits/<SHA> -H "Accept: application/vnd.github.v3.diff"
```

Or in a clone: `git show <SHA>`.

## Get file/directory contents

No direct `gh` command; use the API:

```bash
# File (default branch)
gh api repos/{owner}/{repo}/contents/PATH

# File from ref (branch, tag, or SHA)
gh api "repos/{owner}/{repo}/contents/PATH?ref=main"

# Raw file body (decode base64 from content field, or use raw URL)
gh api repos/{owner}/{repo}/contents/PATH --jq '.content' | base64 -d
```

For raw file content, `curl` is often simpler:

```bash
curl -sL "https://raw.githubusercontent.com/owner/repo/main/PATH"
```

## List repos

```bash
gh repo list [USER] [--limit N]
gh repo list org --limit N
```

For search by name, description, etc., use `gh search repos`; see [search.md](search.md).

## Other repo commands

| Action | Command |
|--------|--------|
| Create repo | `gh repo create [name] [--public \| --private]` |
| Fork | `gh repo fork [owner/repo]` |
| Archive / unarchive | `gh repo archive`, `gh repo unarchive` |
