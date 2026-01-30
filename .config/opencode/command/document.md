---
description: Generate a README.md for a feature, co-located with the feature's entry point. Targets engineers working within the codebase.
---

# Document Feature

You are tasked with creating a README.md file to document a feature in a codebase end-to-end by researching the codebase and synthesizing findings.

The user will provide the feature being documented and a file denoting its entry point.

## **CRITICAL**
- Your purpose is to analyze and create a README file
- Leverage sub-agents to gather information
- This is a READ-ONLY operation until the final write step

## What We Are NOT Doing
- Making any changes to the code
- Proposing any changes to the code
- Running any builds, tests, or scripts

## Steps to Execute

<execute-steps>

### 1. **Check for Existing README**
- Determine the directory of the provided entry point file
- Check if a `README.md` already exists in that directory
- **If one exists**: STOP and warn the user. Do not proceed without explicit instructions on how to handle the conflict (e.g., overwrite, rename, choose different location)

### 2. **Validate What You Will Be Documenting**
- Ask the user follow-up questions to narrow in on exactly what the feature is
- Clarify the scope of documentation:
  - Should you document only a portion (e.g., backend only)?
  - Or should you document end-to-end?
- When you believe you understand the feature, summarize your understanding and ask the user for confirmation before proceeding

### 3. **Plan the Research Approach**
- Consider the underlying patterns, connections, and architecture the feature could have
- Identify specific components, patterns, or concepts to investigate
- Consider which directories, files, or architectural patterns are relevant
- Outline what information you need to gather

### 4. **Execute Research**

Spawn sub-agents to gather information in phases. Each phase must complete before the next begins, but agents within a phase should run in parallel.

**Phase 1 - Locate:**
- Use `@code-locator` to find WHERE relevant files and components live
- Spawn multiple instances in parallel to cover different aspects of the feature (e.g., frontend, backend, shared utilities, tests)
- Each instance should focus on a specific area or component
- **WAIT** for ALL `@code-locator` instances to complete before proceeding

**Phase 2 - Find Patterns:**
- Use `@code-pattern-finder` to find examples of similar implementations and usage patterns
- Spawn multiple instances in parallel to search for different patterns identified from Phase 1
- **WAIT** for ALL `@code-pattern-finder` instances to complete before proceeding

**Phase 3 - Analyze:**
- Use `@code-analyzer` to deep dive into HOW specific code works
- Spawn multiple instances in parallel to analyze different components discovered in Phases 1 and 2
- Each instance should focus on understanding a specific component or subsystem
- **WAIT** for ALL `@code-analyzer` instances to complete before proceeding

**Sequencing Rules:**
- Phases MUST execute in order: Locate → Find Patterns → Analyze
- Within each phase, spawn agents in parallel for efficiency
- Never mix agent types in the same parallel execution
- Each phase informs the next - use findings to guide subsequent phases

### 5. **Synthesize Findings**
- Compile all sub-agent results
- Connect findings across different components
- Identify key file paths and line numbers for reference
- Highlight patterns, connections, and architectural decisions

### 6. **Preview & Confirm (USER CHECKPOINT)**

Present the user with a preview before generating the final README:

**a) Proposed Location:**
- Based on the entry point and research findings, suggest the most appropriate directory for the README
- Format: "I recommend placing the README at `[path]/README.md` because [reasoning]"
- Ask the user to confirm or provide an alternative location

**b) Proposed Structure:**
- Show the section headers and key findings for each section
- Format:
  ```
  ## Feature Documentation: [Name]
  
  ## Summary
  - [2-3 key points about what will be covered]
  
  ## Extending
  ### [Extension Point 1]
  - [Key findings: what, why, where]
  
  ### [Extension Point 2]
  - [Key findings: what, why, where]
  
  ## How It Works
  ### [Component 1]
  - [Key findings preview]
  
  ### [Component 2]
  - [Key findings preview]
  
  ## Code References
  - [Count of references to be included]
  
  ## Architecture
  - [Key architectural patterns discovered]
  ```

- Ask: "Does this structure align with what you're looking for? Should I add, remove, or modify any sections?"

**WAIT for user confirmation before proceeding to step 7.**

### 7. **Generate README.md**

Write the README to the confirmed location with this structure:

```markdown
# [Feature Name]

[Synopsis of the feature]

## Extending

### [Extendable Portion 1]
- **Why extend**: [Reason to extend this portion]
- **Where to modify**: 
  - `path/to/file.ts:123` - [What to change]
  - `another/file.ts:45` - [What to change]
- **Gotchas**: [Things to watch out for]

### [Extendable Portion 2]
- **Why extend**: [Reason to extend this portion]
- **Where to modify**: 
  - `path/to/file.ts:123` - [What to change]
- **Gotchas**: [Things to watch out for]

## How It Works

### [Component/Area 1]
- [Finding with reference (file.ext:line)]
- [Connection to other components]
- [Implementation details]

[Diagrams and code blocks demonstrating the feature]

### [Component/Area 2]
- [Finding with reference (file.ext:line)]
- [Connection to other components]
- [Implementation details]

[Diagrams and code blocks demonstrating the feature]

## Code References

| File | Description |
|------|-------------|
| `path/to/file.ts:123` | Description of what's there |
| `another/file.ts:45-67` | Description of the code block |
| `path/to/tests.spec.ts` | Test file for the feature |

## Architecture

[Patterns, conventions, and design decisions discovered]

[Diagrams illustrating the architecture]
```

</execute-steps>

## Important Notes
- **NEVER write the README with placeholder values** - all content must be based on research findings
- Use diagrams and code blocks frequently - avoid walls of text
- Focus on finding concrete file paths and line numbers for developer reference
- Consider cross-component connections and architectural patterns
- Find examples and usage patterns, not just definitions
- Always read mentioned files FULLY before spawning sub-tasks
- Follow the numbered steps exactly
- Run agents of the same phase in parallel for efficiency

<user-feature-description>

$ARGUMENTS

</user-feature-description>
