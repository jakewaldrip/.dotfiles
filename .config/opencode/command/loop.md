---
description: Execute the next available phase from a PRD
---

## Overview

This command is designed to be run in a loop until all phases of a PRD are completed. Each invocation will:
1. Find the next eligible phase to work on
2. Execute that phase according to its plan
3. Update the plan and PRD as work progresses
4. Signal completion or blocking status for external loop detection

## Exit Signals

**CRITICAL**: At the end of execution, you MUST output exactly one of these signals on its own line for external loop detection:

- `[LOOP_SIGNAL:PHASE_COMPLETE]` - Phase was completed successfully
- `[LOOP_SIGNAL:PHASE_BLOCKED]` - Phase is blocked and cannot continue
- `[LOOP_SIGNAL:ALL_PHASES_COMPLETE]` - All phases in the PRD are now complete
- `[LOOP_SIGNAL:NO_ELIGIBLE_PHASE]` - No phase is available to work on (all are blocked or have unmet dependencies)

## Execution Steps

1. Parse the PRD path from the user prompt below:

<user-prompt>
$ARGUMENTS
</user-prompt>

2. Read and parse the PRD file to understand:
    - The high-level goals
    - All phases, their statuses, dependencies, and linked plans

3. Determine the next eligible phase to work on:
    - Find the first phase (by number) with status "Open"
    - Verify all phases listed in "Depends On" have status "Completed"
    - If no eligible phase exists:
        - If all phases are "Completed", output `[LOOP_SIGNAL:ALL_PHASES_COMPLETE]` and stop
        - Otherwise, output `[LOOP_SIGNAL:NO_ELIGIBLE_PHASE]` and stop

4. Update the PRD to mark the selected phase as "In Progress"

5. Read the plan file linked to this phase:
    - If the plan file does not exist at the specified path, mark the phase as "Blocked" in the PRD, add a note explaining the plan file is missing, and output `[LOOP_SIGNAL:PHASE_BLOCKED]`
    - Understand the following from the plan:
        - The overview and prerequisites
        - Key files to work with
        - Patterns to follow
        - The implementation checklist
        - Success criteria

6. Load any relevant skills based on the plan content:
    - If the plan involves database changes, load the `database-migration` skill
    - If the plan involves running tests, load the `test-running` skill
    - If the plan involves React components, load the `react-component-writing` skill
    - Review available skills and load any others that may be relevant to the implementation

7. Use the todo tool to track your progress through the implementation checklist items

8. Execute the implementation:
    - Work through each item in the implementation checklist
    - As you complete each checklist item, update the plan file to mark it as checked (`- [x]`)
        - Mark items as complete IMMEDIATELY after finishing each item
        - Do not batch multiple completions together
        - Update the plan file before moving to the next checklist item
    - Add any relevant observations or decisions to the "Notes for Next Phase" section in the plan
    - **IMPORTANT**: Be autonomous. Do NOT ask for human input unless absolutely necessary. If you encounter an issue, attempt to resolve it yourself first. Only block if you:
        - Cannot fix failing tests after multiple attempts
        - Encounter a fundamental architectural issue that requires human decision
        - Discover the plan is fundamentally flawed and cannot proceed
        - Have gone off track and cannot recover

9. Verify success criteria:
    - Run through each item in the Success Criteria section
    - Run type checking if specified
    - Run relevant tests, especially any you created
    - As you verify each criterion, mark it as checked in the plan file (`- [x]`)
    - If verification fails and you cannot fix it, mark the phase as "Blocked" in the PRD, add a note explaining why in the plan, and output `[LOOP_SIGNAL:PHASE_BLOCKED]`

10. Create a commit for this phase's work:
    - Stage all relevant changes with `git add`
    - Use the `graphite_run_gt_cmd` tool with `gt create` to create a branch and commit
    - Branch naming convention: `phase-X-short-description` (e.g., `phase-1-label-description-migration`)
        - Use the `--branch` flag to specify the branch name: `gt create --all --branch "phase-1-label-description-migration" --message "feat: Phase 1 - Add label_description table migration"`
    - The commit message should reference the phase number and a brief description
    - Do NOT push or submit the changes (no `gt submit`)

11. Update the PRD:
    - Change the phase status from "In Progress" to "Completed"

12. Output the appropriate exit signal:
    - If this was the last phase and all are now complete: `[LOOP_SIGNAL:ALL_PHASES_COMPLETE]`
    - Otherwise: `[LOOP_SIGNAL:PHASE_COMPLETE]`

## Handling Blocked States

If at any point you determine you cannot continue, you MUST:

1. Update the plan file:
    - Check off any completed items in the implementation checklist
    - Add a clear explanation in "Notes for Next Phase" describing:
        - What was accomplished
        - What is blocking progress
        - Any relevant error messages or context

2. Update the PRD:
    - Change the phase status to "Blocked"

3. Commit any partial work (if meaningful):
    - Use the `graphite_run_gt_cmd` tool with `gt create` with a message like "wip: Phase X - partial progress (blocked)"

4. Output `[LOOP_SIGNAL:PHASE_BLOCKED]`

## Important Reminders

- **Autonomy**: Solve problems yourself. Do not ask for human input unless truly stuck.
- **Update as you go**: Check off implementation items and update notes incrementally, not all at once at the end.
- **Be precise**: When updating the PRD status, ensure you match the exact format (e.g., `Status: Completed` not `Status: Done`).
- **No pushing**: Commit your work but do NOT push to remote. The external loop will handle that.
- **Deterministic signals**: Always end with exactly one `[LOOP_SIGNAL:*]` output for the external bash script to detect.
