---
description: Create a readme targeting developers in the code base for the end to end functionality of a feature. How to use and how to integrate with it.
---

# Document Feature

You are tasked with creating a README.md file to document a feature in a code base end to end by spawning subtasks and synthesizing their findings.

The user will provide the feature we are discussing as well as a file denoting its entry point.

## **CRITICAL**
- Use **code-locator** for locating relevant files
- Use **code-analyzer** for analyzing the files found by code-locator
- Use **code-pattern-finder** for finding codebase patterns as needed
- Your purpose is to analyze and create a README file, leverage the subagents to find the information you need

## What we are not doing
- Making any changes to the code
- Proposing any changes to the code
- Running any builds or tests or scripts

<execute-steps>
1. **Validate what it is that you will be documenting:**
    - Ask the user follow up questions to narrow in on exactly what the feature being documented is
    - Narrow in on the scope of what you will be documenting
        - You want to find out if you should document only a portion of the feature (e.g. the backend), or if you should generate documetation end to end
    - When you think you have the answer, ask the user for confirmation and proceed when they verify that you are documenting the correct feature

2. **Detail the steps needed to perform the research:**
    - Take time to think about the underlying patterns, connections, and architectural the feature could have
    - Identify specific components, patterns, or concepts to investigate
    - Lay out what the code-locator or notes-locator should look for
    - Specify what patterns the code-pattern-finder should look for
    - Be clear that locators and pattern-finders collect information for analyzers
    - Typically run a single code-analyzer and notes-analyzer (in parallel if both needed)
    - Consider which directories, files, or architectural patterns are relevant

3. **Spawn tasks for comprehensive research (follow this sequence):**

   **Phase 1 - Locate (Codebase & Notes):**
   - Identify all topics/components/areas you need to locate
   - Group related topics into coherent batches
   - Spawn **code-locator** agents in parallel for each topic group to find WHERE files and components live
   - Simultaneously spawn **notes-locator** agents in parallel to discover relevant documents
   - **WAIT** for all locator agents to complete before proceeding

   **Phase 2 - Find Patterns (Codebase only):**
   - Based on locator results, identify patterns you need to find
   - Use **code-pattern-finder** agents to find examples of similar implementations
   - Run multiple pattern-finders in parallel if searching for different unique patterns
   - **WAIT** for all pattern-finder agents to complete before proceeding

   **Phase 3 - Analyze (Codebase & Notes):**
   - Using information from locators and pattern-finders, determine what needs deep analysis
   - Group analysis tasks by topic/component
   - Spawn **code-analyzer** agents in parallel for each topic group to understand HOW specific code works
   - Spawn **notes-analyzer** agents in parallel to extract key insights from the most relevant documents found
   - **WAIT** for all analyzer agents to complete before synthesizing

   **Important sequencing notes:**
   - Each phase builds on the previous one - locators inform pattern-finding, both inform analysis
   - Run agents of the same type in parallel within each phase
   - Never mix agent types in parallel execution
   - Each agent knows its job - just tell it what you're looking for
   - Don't write detailed prompts about HOW to search - the agents already know

4. **Wait for all sub-agents to complete and synthesize findings:**
   - **IMPORTANT**: Wait for ALL sub-agent tasks to complete before proceeding
   - Compile all sub-agent results (both codebase and notes findings)
   - Prioritize live codebase findings as primary source of truth
   - Use notes/ findings as supplementary historical context
   - Connect findings across different components
   - Include specific file paths and line numbers for reference
   - Highlight patterns, connections, and architectural decisions


5. **Generate README.md document:**
   - Filename: `notes/readmes/date_topic.md`
   - **IMPORTANT**: Use diagrams and codeblocks frequently. Avoid walls of text in describing a feature, instead prefer to show how its used and where the pieces connect
   - Structure the document with YAML frontmatter followed by content following the template below:
     ```markdown
     ## Feature Documentation
     [Name of the feature]

     ## Summary
     [Synopsis of the feature]

     ## Extending

     ### [Extendable Portion of Feature 1]
     - Why you might want to extend this portion of the feature (e.g. adding a new column to a filter so that we can filter on additional data)
     - All locations where you would need to add code to extend this portion of the feature (e.g. add a new property to the filter object and update the SQL)
     - Gotchas and things to keep in mind

     ### [Extendable Portion of Feature 2]
     - Why you might want to extend this portion of the feature (e.g. supporting a new market or partner in the feature so that we can onboard a new market)
     - All locations where you would need to add code to extend this portion of the feature (e.g. adding a condition to the market slug check)
     - Gotchas and things to keep in mind

     ## Detailed findings

     ### [Component/Area 1]
     - Finding with reference ([file.ext:line])
     - Connection to other components
     - Implementation details
     - Diagrams and code blocks demostrating the feature

     ### [Component/Area 2]
     - Finding with reference ([file.ext:line])
     - Connection to other components
     - Implementation details
     - Diagrams and code blocks demostrating the feature
     ...

     ## Code References
     - `path/to/file.py:123` - Description of what's there
     - `another/file.ts:45-67` - Description of the code block
     - `path/to/tests.spec.ts` - Path to a test file for the feature

     ## Architecture Insights
     [Patterns, conventions, and design decisions discovered with diagrams]

     ## Historical Context (from notes/)
     [Relevant insights from notes/ directory with references]
     - `notes/research/something.md` - Historical decision about X
     - `notes/plans/build-thing.md` - Past exploration of Y
     ```
 </execute-steps>


## Important notes:
- Follow the three-phase sequence: Locate → Find Patterns → Analyze
- Use parallel Task agents OF THE SAME TYPE ONLY within each phase to maximize efficiency and minimize context usage
- Always run fresh codebase research - never rely solely on existing research documents
- Focus on finding concrete file paths and line numbers for developer reference
- Research documents should be self-contained with all necessary context
- Each sub-agent prompt should be specific and focused on read-only operations
- Consider cross-component connections and architectural patterns
- Include temporal context (when the research was conducted)
- Keep the main agent focused on synthesis, not deep file reading
- Encourage sub-agents to find examples and usage patterns, not just definitions
- Explore all of notes/ directory, not just research subdirectory
- **File reading**: Always read mentioned files FULLY (no limit/offset) before spawning sub-tasks
- **Critical ordering**: Follow the numbered steps exactly
  - ALWAYS read mentioned files first before spawning sub-tasks (step 1)
  - ALWAYS wait for all sub-agents to complete before synthesizing (step 4)
  - NEVER write the research document with placeholder values

<user-feature-description>
$ARGUMENTS
</user-feature-description>
