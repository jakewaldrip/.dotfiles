---
name: nx-project-mapping
description: Maps file paths to Nx project names in the Commons monorepo. Use when you need to determine which Nx project a file belongs to for running tests, linting, or other Nx commands.
---

# Nx Project Mapping

Maps file paths to Nx project names using the project graph.

## Get Project Mappings

```bash
npx nx graph --file=stdout | jq '.graph.nodes | to_entries | map({name: .key, root: .value.data.root})'
```

**If `jq` is not installed**, parse the JSON directly—the output is `{ "graph": { "nodes": { "<project-name>": { "data": { "root": "<path>" } } } } }`.

Example output:
```json
[
  { "name": "commons", "root": "commons" },
  { "name": "@commons/backend", "root": "commons-packages/backend" },
  { "name": "@cityblock/api", "root": "packages/cityblock-api" },
  { "name": "process-ciox-pdf", "root": "cloud_functions/process-ciox-pdf" }
]
```

## Match File to Project

Use **longest-prefix matching**: find the project whose `root` is the longest prefix of the file path.

| Step | Action |
|------|--------|
| 1 | Normalize file path (relative to repo root) |
| 2 | Sort projects by root length (longest first) |
| 3 | Return first project whose root is a prefix of the file path |

**Example:** `commons-packages/backend/services/member-service.ts` → `@commons/backend`
