import { tool } from "@opencode-ai/plugin"

const TARGET_PREFERENCES = {
  typecheck: ["lint:tsc:check"],
  lint: ["lint:check", "lint:eslint:check"],
  test: ["test:jest:run", "test:run"],
} as const

export default tool({
  description:
    "Resolve the owning Nx project for a file in the Commons monorepo and return its canonical root plus the typecheck/lint/test target names and ready-to-run commands. Use this instead of hand-rolling `nx graph`/jq to find which project a file belongs to before running tsc, ESLint, or Jest.",
  args: {
    file: tool.schema
      .string()
      .describe("Path to a source file (repo-relative or absolute)"),
  },
  async execute(args, context) {
    const { $ } = await import("bun")
    const path = await import("node:path")
    const fs = await import("node:fs")

    const root = context.directory
    const abs = path.isAbsolute(args.file)
      ? args.file
      : path.join(root, args.file)

    // 1. Cheap nearest-package.json walk to find the owning project name.
    let dir = path.dirname(abs)
    let projectName: string | undefined
    while (dir.startsWith(root)) {
      const pkg = path.join(dir, "package.json")
      if (fs.existsSync(pkg)) {
        try {
          const name = JSON.parse(fs.readFileSync(pkg, "utf8")).name
          if (name) {
            projectName = name
            break
          }
        } catch {
          /* ignore malformed package.json */
        }
      }
      if (dir === root) break
      dir = path.dirname(dir)
    }

    if (!projectName) {
      // Fall back to Nx's affected-by-file (owning project is first line).
      const out =
        await $`npx nx show projects --affected --files=${args.file}`.cwd(root).quiet().nothrow().text()
      projectName = out.split("\n").map((s) => s.trim()).filter(Boolean)[0]
    }
    if (!projectName) return `Could not resolve an Nx project for ${args.file}`

    // 2. Canonical root + target list from Nx (source of truth).
    const json = await $`npx nx show project ${projectName} --json`.cwd(root).quiet().nothrow().text()
    let projectRoot = ""
    let targets: string[] = []
    try {
      const parsed = JSON.parse(json)
      projectRoot = parsed.root ?? ""
      targets = Object.keys(parsed.targets ?? {})
    } catch {
      /* nx output unparseable; targets stay empty */
    }

    const pick = (prefs: readonly string[]) =>
      prefs.find((t) => targets.includes(t))

    const typecheck = pick(TARGET_PREFERENCES.typecheck)
    const lint = pick(TARGET_PREFERENCES.lint)
    const test = pick(TARGET_PREFERENCES.test)
    const rel = projectRoot && abs.startsWith(path.join(root, projectRoot))
      ? path.relative(path.join(root, projectRoot), abs)
      : undefined

    const lines = [
      `project: ${projectName}`,
      `root: ${projectRoot || "(unknown)"}`,
      typecheck
        ? `typecheck: npx nx run "${projectName}:${typecheck}"`
        : "typecheck: (no tsc target found)",
      lint
        ? `lint: npx nx run-many --targets "${lint},format:check" -p ${projectName}`
        : "lint: (no lint target found)",
      test && rel
        ? `test (this file): npx nx ${test} ${projectName} -- --runTestsByPath ${rel}`
        : test
          ? `test: npx nx ${test} ${projectName}`
          : "test: (no jest target found)",
    ]
    return lines.join("\n")
  },
})
