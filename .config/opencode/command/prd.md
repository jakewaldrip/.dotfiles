---
description: Create a PRD for Ralph to tackle
---

## Overview

### Deliverable 1

- Location: `notes/plans`
- Naming schema: You may name these to be specific to the current task it will tackle, prepended by the phase number. For example, `phase_1_label_description_migration.md`, and `phase_2_replace_joins.md`
- Details: In addition to the PRD markdown file, you will also be generating discrete plan files and linking them into the PRD by file name

### Deliverable 2

- Location: `notes/prds`
- Naming schema: Structure the name with the date, followed by a description of the tasks (short). For example, you would have `12-01-2026_task_label_refactor.md`.
- Details: You are building a PRD for agent consumption. Your deliverable is a file stored in `notes/prds`. The goal of this file is to act as a kanban board for the agents to pick up tasks off of. It is **very important** that each of these tasks specifically link to a plan. This will be the end result of the planning here so you will do it last

#### Template for PRD

```markdown
# [PRD Title, 1-5 words]

## High Level Goals
[what we are trying to accomplish with this PRD]

## Phases

### Phase 1

Description: [short description for the phase]
Purpose: [short blurb on why we are doing this phase and how it will help us accomplish our goals]
Status: Open
Depends On: None
Plan: [Relative path to the file in `notes/plans`]

### Phase 2

Description: Replace joins in existing `task` queries to get task labels from the `label_description` table
Purpose: The existing task tables should use our newly created label_description table in existing queries. This will allow us to cutover to the new method
Status: Open
Depends On: Phase 1
Plan: `notes/plans/phase_2_replace_joins.md`
```

#### Template for Plan Files

```markdown
# Phase [X]: [Title]

## Overview
[Brief description of what this phase accomplishes and why it matters in the context of the larger PRD]

## Prerequisites
- [Any prior phases that must be completed first]
- [Any context or files that should be reviewed before starting]

## Pre-flight Checklist
- [ ] Load relevant skills: [example skill #1], [example skill #2]
- [ ] Read pattern files listed in Key Files section
- [ ] Run codegen if GraphQL schema changed in previous phase

## Key Files
| File | Purpose | Lines of Interest |
|------|---------|-------------------|
| `path/to/file.ts` | Brief description | L123-145 |

## Patterns to Follow
[Describe specific patterns the implementing agent should follow, reference existing code examples where applicable. Include code snippets where easily available.]

## Implementation Checklist
- [ ] Step 1: [Specific actionable task]
- [ ] Step 2: [Specific actionable task]
- [ ] ...

## Success Criteria
- [ ] [Specific verifiable outcome]
- [ ] [Type checking passes: `npm run typecheck` or equivalent]
- [ ] [Relevant tests pass: `npm test path/to/relevant.test.ts`]
- [ ] [Any new tests created by this phase pass]

## Notes for Next Phase
[Any context, decisions made, or observations the next agent should be aware of]
```

## Execution Steps

1. Use the todo tool to break down the work you need to do to create a PRD. A good guideline would be the execution steps as laid out here, but you may add additional ones or make changes if needed

2. Consider the user prompt below. This prompt will be a description of the problem or feature that we are creating this PRD for

<user-prompt>
$ARGUMENTS
</user-prompt>

 - If you find a reference to a linear ticket (ENG-XXX), use @linear-analyzer subagent to analyze the ticket(s) and consider their content

3. Now we want to ask the user questions. Your goal here is to zero in on the scope of the work and important behaviors that might be required

4. At this point, we begin generating a full understanding of the code. You need a complete understanding of the code in its current state to generate the plans. Follow these sub-steps to do so
    a. Invoke @code-locator agents in parallel to find the files that you need
    b. WAIT until these have ALL completed
    c. Invoke @code-analyzer agents in parallel on the files you deem important to analyze
    d. WAIT until these have ALL completed
    e. Invoke @code-pattern-finder agents in parallel on any patterns that you might need to find within the code
    f. WAIT until these have ALL completed

5. Now that we understand the code and what the user wants to accomplish, we need to break the task down into individual steps
    - It is absolutely critical that these steps are indepedently accomplishable. It is okay if they rely on happening in order, but we want each phase to be its own pull request
    - You can decide how many phases are needed, it is possible that the feature is small enough where it can be done in one pull request, or it might need 10 separate phases to complete. It is important here that we be precise and realistic in the amount of work that an agent can accomplish in a single session
    - Each phase will be discrete and accomplished by one agent in one session, and that work will be committed. Keep that in mind when creating your phases

6. Finally, we can create our plans.
    - You have
        - The users request
        - An understanding of the current state of the code surrounding this request
        - The discrete phases that you want the task to be accomplished within
    - Use this information to create a **SEPERATE** plan file for EACH phase
    - **IMPORTANT** Follow the "Template for Plan Files" defined above when creating each plan
        - The plan will be a high level approach for tackling this task. Be specific and perscriptive in how this task gets handled. You have the context, they do not yet
            - For example, if phase 1 is create a database table, give it the exact shape of the database table it should create, tell it what methods the model should have, etc
        - Give details on patterns they should follow for various functionality, and important files to keep in mind for working on this functionality
            - Provide file names and line numbers if possible when doing this
    - **IMPORTANT** When generating plans, use a checklist style approach to ensure the implementing agent can keep track of the changes they've made and what they have left to do

7. With the plans created, we can create our PRD
    - Follow the PRD template as described in this file
    - **IMPORTANT** Provide the relative filepath to each plan/phase in the section for that plan/phase. If the agent doing the work cannot find the plan then what you have done is for nothing

8. Verify that you have fulfilled the following deliverables
    - a PRD markdown file in `notes/prds`
    - Each phase of the PRD is accounted for in the file, with a corresponding plan linked to it
    - Each phase has a plan markdown file associated with it
