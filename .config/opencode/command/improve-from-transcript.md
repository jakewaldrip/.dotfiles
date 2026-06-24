---
description: Analyze an exported opencode transcript and propose config improvements (AGENTS.md, skills, commands, plugins, custom tools, scripts)
---

# Improve From Transcript

You are tasked with analyzing an **exported opencode session transcript** and proposing concrete improvements to the opencode configuration that would have resulted in **less steering, higher first-pass accuracy, and a tighter feedback loop**.

You operate in the **same working directory** the analyzed session took place in. This means you can cross-reference the real files, the in-effect `AGENTS.md`, and the existing skills/commands/plugins/tools to ground every recommendation in reality.

## Philosophy

The transcript is evidence, not gospel. Your job is forensic:
- Find the moments where the agent was **steered** (corrected, re-prompted, reversed).
- Find the moments where the agent was **inaccurate** (wrong guesses, failed edits, re-reads, assumptions later corrected).
- Find the moments where the **feedback loop dragged** (verification deferred, late/missing tests, long discovery sequences, manual steps that could be automated).
- Find the **config gaps** (a skill that should have loaded but didn't; a rule that was missing or wrong; a referenced-but-absent skill).

Then map each finding to the **right kind of intervention** and propose it concretely (exact diffs and exact new-file contents), ranked by impact-vs-effort. Apply nothing until the user approves.

**Important:** A transcript may contain no user messages at all (a long autonomous run). In that case, the most important friction lives *outside* the transcript — failed tests, broken UI, review churn, follow-up sessions. The interactive friction interview (Step 5) is how you recover it.

## Transcript Format Reference

The exported transcript is **Markdown** (not raw JSON). Parse it with these conventions:

- Begins with a `# <title>` header followed by a metadata block: `**Session ID:**`, `**Created:**`, `**Updated:**`.
- Each turn is a heading:
  - `## Assistant (Build · <model> · <duration>)` — an assistant turn.
  - `## User` — a user turn (steering signal).
- Within an assistant turn:
  - Plain prose is the assistant's **reasoning/narration**.
  - A tool call renders as `**Tool: <name>**` followed by `**Input:**` (a fenced ```json block) and `**Output:**` (a fenced block).
- Turns are separated by `---`.
- **Truncation:** exports are capped (~50 KB). If the file appears cut off (e.g., ends mid-block or shows an "Output capped" marker), continue reading with `offset` until you reach the true end. Note in your analysis if the transcript was truncated, since later friction may be unseen.

## Execution Steps

<execute-steps>

1. **Parse the argument.** Read the transcript path from `$ARGUMENTS` below. Verify the file exists. Read it **fully** (no limit/offset). If it was truncated at the export cap, continue reading with increasing `offset` until the end. If no path was provided, ask the user for one.

2. **Parse the transcript.** Extract and hold in mind:
   - Session metadata (title, id, created/updated, elapsed time).
   - The ordered list of turns (assistant vs. user).
   - Every tool call: name, input, and output (especially failures).
   - Assistant reasoning prose.
   - Every user message (these are direct steering signals — quote them).

3. **Load the current config context** so recommendations build on what exists and surface gaps. Read/enumerate:
   - The in-effect `AGENTS.md`.
   - `skills/` (names + descriptions of existing skills).
   - `command/` (existing commands).
   - `plugins/` (existing plugins, if any).
   - `tools/` (existing custom tools, if any).
   - Note any **skill referenced in `AGENTS.md` that does not actually exist** — that is a concrete gap.
   - **Ignore `.cursor/` and `.claude/` directories and any skills within them.** These are ignored at the opencode level, so never read them for context or propose interventions that live in them.

4. **Analyze for friction.** Classify findings into four buckets. For each finding, capture transcript **evidence** (quote the prose, tool call, or line reference):
   - **Steering events** — user corrections; "no / actually / instead / not quite"; re-prompts; reversed directions; repeated clarifications.
   - **Accuracy gaps** — wrong file/API/path guesses; hallucinated symbols; failed or reverted edits; re-reading the same file; assumptions later corrected; over-narrow `offset/limit` reads that miss context.
   - **Feedback-loop drag** — verification (tsc/lint/codegen/tests) deferred to the very end or skipped; long discovery sequences (repeated `read`/`grep`/`rg` that a skill or custom tool could shortcut); one-at-a-time edits that could be batched; manual ceremony that could be automated.
   - **Skill/AGENTS misses** — a moment where an existing skill should have been loaded but wasn't; a missing, ambiguous, or wrong rule; a referenced-but-absent skill.

5. **Interactive friction interview.** After transcript analysis, ask the user targeted questions about friction the transcript cannot show. Tailor the questions to what you observed, but cover this bank:
   - Did the resulting PR's **tests** fail (CI or local)? Which ones?
   - Did a **lint / typecheck / build** check fail afterward?
   - Was the resulting **UI incorrect** or did it need visual rework?
   - Did you open a **follow-up session** to fix something from this work? (If so, that friction belongs here.)
   - Was there **review churn** — comments that pointed at avoidable mistakes?
   - Anything the agent did that you had to **undo or redo manually**?
   Offer that the user can provide those artifacts (CI logs, lint output, screenshots, the follow-up transcript) if they want deeper analysis. Fold all answers into the findings from Step 4.

6. **Map findings → concrete interventions.** For each significant finding, choose the **right artifact** and draft it concretely. Use the decision guide below.

   **Artifact menu:**
   - **AGENTS.md** — a durable rule or convention that should always apply. Propose an **exact diff**.
   - **Skill** — reusable domain/tool knowledge or a workflow the agent should load on demand. Propose a new `skills/<name>/SKILL.md` with `name`/`description` frontmatter, plus supplemental files if the body would be large (load-on-demand pattern).
   - **Command** — a repeatable, user-invoked multi-step workflow. Propose a new `command/<name>.md` with `description` frontmatter.
   - **Plugin** — *event-driven* automation that reacts to harness events without the model choosing to act. Propose a `plugins/<name>.ts` using `@opencode-ai/plugin`. Choose a **valid** hook (see vocabulary below) — e.g., `tool.execute.after` to auto-run typecheck after edits, `file.edited` to trigger lint, `session.idle` for notify/auto-verify, `experimental.session.compacting` to preserve task state.
   - **Custom tool** — a *model-invokable* deterministic action that gives the agent a reliable primitive it would otherwise hand-roll. Propose a `tools/<name>.ts` using the `tool` helper (`tool({ description, args, execute })`), optionally shelling out to a script in any language via `Bun.$`.
   - **Script** — the underlying executable that closes a manual loop (e.g., a verify/watch ladder). Reference it from a command, plugin, or custom tool.

   **Decision guide (which artifact?):**
   - It's a **durable rule** the agent must always follow → **AGENTS.md**.
   - It's **knowledge** the agent needs only sometimes → **skill**.
   - It's a **workflow the user kicks off** → **command**.
   - It should **fire automatically on an event** (the model doesn't decide) → **plugin**.
   - It's a **primitive the model should call on demand** instead of improvising a fragile sequence → **custom tool**.
   - It's the **raw executable** a tool/plugin/command wraps → **script**.
   - Plugin vs. custom tool, sharply: a **plugin** fires on a harness **event**; a **custom tool** is **called by the model**.

7. **Rank recommendations** by impact-vs-effort (highest leverage first). For each, present:
   - **Friction addressed** — with transcript evidence (quote / line ref) and any interview findings.
   - **Proposed artifact** — type + exact content or diff.
   - **Expected effect** — on steering, accuracy, and loop-speed.

8. **Write the report** to `notes/transcript-analysis_<MM-DD-YYYY>_<short-desc>.md` using the report template below.

9. **Confirmation gate.** Present the ranked list and ask the user **which recommendations to apply**. Apply only the approved ones. When applying:
   - For `AGENTS.md` and `command/*` edits, respect the **dotfiles symlink convention** — these are symlinks into `~/.dotfiles/.config/opencode/`; edit the real file at the symlink target, not the link.
   - Place `plugins/*.ts` in `~/.config/opencode/plugins/` and `tools/*.ts` in `~/.config/opencode/tools/`.
   - Place skills in `~/.config/opencode/skills/<name>/SKILL.md`.

Use the todowrite tool to create a structured task list for the steps above, marking each pending initially. Step 6 may expand into multiple sub-items, one per proposed artifact.

</execute-steps>

## Valid Plugin Event Vocabulary

Only propose plugins that hook real events. Available events:

- **Command:** `command.executed`
- **File:** `file.edited`, `file.watcher.updated`
- **Installation:** `installation.updated`
- **LSP:** `lsp.client.diagnostics`, `lsp.updated`
- **Message:** `message.part.removed`, `message.part.updated`, `message.removed`, `message.updated`
- **Permission:** `permission.asked`, `permission.replied`
- **Server:** `server.connected`
- **Session:** `session.created`, `session.compacted`, `session.deleted`, `session.diff`, `session.error`, `session.idle`, `session.status`, `session.updated`
- **Todo:** `todo.updated`
- **Shell:** `shell.env`
- **Tool:** `tool.execute.before`, `tool.execute.after`
- **TUI:** `tui.prompt.append`, `tui.command.execute`, `tui.toast.show`
- **Compaction hook:** `experimental.session.compacting`

Plugin skeleton:
```ts
import type { Plugin } from "@opencode-ai/plugin"

export const MyPlugin: Plugin = async ({ project, client, $, directory, worktree }) => {
  return {
    "tool.execute.after": async (input, output) => {
      // input.tool is the tool name; react accordingly
    },
  }
}
```

## Custom Tool Conventions

- Live in `~/.config/opencode/tools/` (global) or `.opencode/tools/` (project).
- **Filename = tool name.** Multiple named exports in one file become `<filename>_<exportname>`.
- Use the `tool` helper from `@opencode-ai/plugin` (already a dependency in `~/.config/opencode/package.json`).
- Args use `tool.schema` (Zod). The `execute` fn may shell out to any language via `Bun.$`.
- Context provides `{ agent, sessionID, messageID, directory, worktree }`.

Custom tool skeleton:
```ts
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "What this tool does",
  args: {
    foo: tool.schema.string().describe("..."),
  },
  async execute(args, context) {
    return "result"
  },
})
```

## Skill Conventions

- Live in `~/.config/opencode/skills/<name>/SKILL.md`.
- Frontmatter: `name` and `description` (the description is the trigger the agent matches against).
- For large skills, keep `SKILL.md` lean and add supplemental files loaded on demand (the `axle-api`/`github-cli` pattern).

## Report Template

```markdown
# Transcript Analysis: [session title]

**Transcript:** [path]
**Session:** [id] · [created] → [updated] ([elapsed])
**Analyzed:** [date]
**Truncated:** [yes/no — note if export cap was hit]

## Summary
[2-4 sentences: what the session did, and the headline friction themes.]

## Friction Findings

### Steering
- [Finding] — Evidence: [quote / line ref]

### Accuracy
- [Finding] — Evidence: [quote / line ref]

### Feedback Loop
- [Finding] — Evidence: [quote / line ref]

### Config Gaps
- [Finding] — Evidence: [quote / line ref]

## Out-of-Band Friction (from interview)
- [Tests/lint/UI/follow-up findings the user reported]

## Recommendations (ranked)

### 1. [Title] — [AGENTS.md | Skill | Command | Plugin | Custom Tool | Script]
- **Friction addressed:** [...] (evidence: [...])
- **Proposed change:**
  [exact diff or new-file contents]
- **Expected effect:** [steering / accuracy / loop-speed]

### 2. ...

## Not Recommended / Deferred
- [Things considered but judged low-leverage, with a one-line why.]
```

<transcript>

**transcript path**

$ARGUMENTS

</transcript>
