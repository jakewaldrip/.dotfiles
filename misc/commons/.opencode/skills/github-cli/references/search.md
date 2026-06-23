# gh search

Search uses [GitHub search syntax](https://docs.github.com/en/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax). Use `--limit N` (default 30) and `--order asc|desc`, `--sort` where supported.

**Excluding qualifiers:** A leading `-` in the query can be parsed as a flag. Use `--` before the query so the rest is treated as the query:

```bash
gh search issues -- "my query -label:bug"
```

## Search issues

```bash
gh search issues "QUERY" [OPTIONS]
```

Examples:

```bash
gh search issues "is:open repo:owner/repo"
gh search issues "author:me is:open"
gh search issues "label:bug org:myorg"
```

| Option | Effect |
|--------|--------|
| `--limit N` | Max results |
| `--order asc \| desc` | Order |
| `--sort comments \| reactions \| created \| updated` | Sort field |
| `--state open \| closed` | Issue state (default: open) |
| `--json field1,field2` | Output fields |
| `--web` | Open search in browser |

## Search pull requests

```bash
gh search prs "QUERY" [OPTIONS]
```

Same idea as issues; use `is:pr` in the query if needed. Options mirror `gh search issues` (e.g. `--limit`, `--order`, `--sort`, `--state`, `--json`, `--web`).

## Search repositories

```bash
gh search repos "QUERY" [OPTIONS]
```

Examples:

```bash
gh search repos "org:myorg language:typescript"
gh search repos "topic:react stars:>100"
gh search repos "user:me"
```

| Option | Effect |
|--------|--------|
| `--limit N` | Max results |
| `--sort stars \| forks \| updated` | Sort |
| `--order asc \| desc` | Order |
| `--json field1,field2` | Output fields |
| `--web` | Open in browser |

## Search code

```bash
gh search code "QUERY" [OPTIONS]
```

Examples:

```bash
gh search code "function myFunc repo:owner/repo"
gh search code "TODO language:python org:myorg"
```

| Option | Effect |
|--------|--------|
| `--limit N` | Max results |
| `--order asc \| desc` | Order |
| `--sort indexed` | Sort (code search) |
| `--json field1,field2` | Output fields |
| `--web` | Open in browser |

## Search commits

```bash
gh search commits "QUERY" [OPTIONS]
```

Same pattern: query string, then `--repo owner/repo`, `--limit`, `--order`, `--sort`, `--json`, `--web` as needed.
