# Chronos Rebuild Instructions

Instructions for rebuilding the Chronos work logging directory structure on a new machine.

## Directory Structure

Create the following directory structure:

```
chronos/
├── .gitignore
├── index.md
├── organization.md
├── archive/
│   └── .gitkeep
├── daily/
│   └── .gitkeep
├── people/
│   └── _template.md
├── projects/
│   └── _template.md
├── topics/
│   └── _template.md
└── vendors/
    └── _template.md
```

## File Contents

### .gitignore

```
.opencode/
```

### index.md

```markdown
# Chronos - Work Log

Personal work logging system with backlinks.

## Structure

| Directory | Purpose |
|-----------|---------|
| `daily/` | Daily log files (YYYY-MM-DD.md) |
| `archive/` | Monthly archives with summaries |
| `projects/` | Project files |
| `people/` | Collaborator files |
| `vendors/` | Vendor/tool files |
| `topics/` | Concept/topic files |

## Entry Types

- `[WORKING]` - Active task
- `[BLOCKED]` - Stuck on something
- `[COMPLETED]` - Finished a task
- `[MEETING]` - Sync with someone
- `[REVIEW]` - Code review, PR review, document review
- `[NOTE]` - General observation

## Quick Commands

- **/start-day** - Creates today's log, shows carry-over items, project status
- **/end-month** - Archive the previous month's daily entries with a summary
- Natural language for everything else

## Monthly Archives

At the end of each month, daily entries are archived to `archive/YYYY_month/` (e.g., `archive/2026_january/`). Each archive contains:
- All daily log files from that month
- A `summary.md` with key accomplishments, project activity, and collaboration statistics

Use the `/end-month` command to archive the previous month's entries.

## Active Projects

<!-- Update as projects become active -->

## Usage Examples

```
"Working on the auth refactor with Sarah"
"Blocked on Braze integration"
"Completed the PR review for Mike"
"What did I do yesterday?"
"What should I do next?"
```
```

### organization.md

This file is organization-specific. Create a blank template or customize for your workplace:

```markdown
# Organization Overview

## Business Foundation

<!-- Description of your organization -->

---

## Main Applications & Services

<!-- Key systems and services -->

---

## Culture

### Values & Principles

<!-- Organization values -->

### Development Workflow

<!-- Team rituals, code review, deployment practices -->
```

### people/_template.md

```markdown
# {{PersonName}}

## Role
<!-- Team / Position -->

## Expertise
<!-- What they're known for -->

## Notes
<!-- High-level interactions, relevant context -->
```

### projects/_template.md

```markdown
# {{ProjectName}}

## Status
Active | Paused | Completed

## Description
<!-- Brief description of the project -->

## Related Tickets
<!-- List relevant tickets -->
- TICKET-XXX: Description

## Summary
<!-- High-level summary of progress, updated periodically -->
```

### topics/_template.md

```markdown
# {{TopicName}}

## Description
<!-- What this concept is -->

## Notes
<!-- Relevant context -->
```

### vendors/_template.md

```markdown
# {{VendorName}}

## Description
<!-- What this vendor/tool does -->

## Usage
<!-- How we use it -->

## Notes
<!-- Relevant context -->
```

## Daily Log Format

Daily files follow this structure (filename: `YYYY-MM-DD.md`):

```markdown
# YYYY-MM-DD

## Carry-over
<!-- Items carried from previous day as regular entries -->

## TODO
<!-- Planned tasks for today - move to Log when started -->

## Log
- HH:MM AM/PM | [ENTRY_TYPE] Description with [[BackLinks]]
```

## Monthly Archive Format

Archive directories use the format `YYYY_month/` (e.g., `2026_january/`).

Each archive contains:
- All daily log files from that month
- A `summary.md` with this structure:

```markdown
# Month YYYY Summary

## Overview
<!-- High-level summary of the month -->

## Key Accomplishments
<!-- Major completions and wins -->

## Active Projects
<!-- Projects worked on during the month -->

## Collaborations
<!-- People collaborated with -->

## Notable Challenges
<!-- Blockers or difficulties encountered -->

## Daily Entries
<!-- List of daily files in the archive -->

## Statistics

| Metric | Count |
|--------|-------|
| Total Entries | X |
| Working Days Logged | X |

### Project Activity
| Project | Mentions |
|---------|----------|

### Collaboration Frequency
| Person | Interactions |
|--------|--------------|
```

## Quick Setup Commands

```bash
# Create the directory structure
mkdir -p chronos/{archive,daily,people,projects,topics,vendors}

# Create .gitkeep files for empty directories
touch chronos/archive/.gitkeep
touch chronos/daily/.gitkeep

# Initialize git repository
cd chronos && git init
```

Then manually create the template files and configuration files as documented above.
