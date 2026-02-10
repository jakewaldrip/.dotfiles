---
description: Archive a month's daily entries to chronos/archive with a generated summary
---

# End Month

Archives daily log entries for a specified month (or the previous month by default) into `chronos/archive/`, generating a summary file for quick reference.

## Usage

```
/end-month [month] [year]
```

- If no arguments: archives the previous month
- If one argument: interprets as month name for current year (e.g., `/end-month january`)
- If two arguments: interprets as month and year (e.g., `/end-month january 2026`)

## Arguments

<user-prompt>
$ARGUMENTS
</user-prompt>

## Execution Steps

1. **Parse Arguments**
   - If no arguments provided, calculate previous month from today's date
   - If arguments provided, parse month name (case-insensitive) and optional year
   - Validate the month/year combination is in the past or current month

2. **Verify Source Files Exist**
   - Scan `daily/` for files matching the target month (YYYY-MM-*.md pattern)
   - If no files found, inform user and exit gracefully

3. **Create Archive Directory**
   - Target: `archive/{year}_{month}/` (e.g., `archive/2026_january/`)
   - Create if it doesn't exist
   - If it already exists with files, warn user and ask for confirmation before overwriting

4. **Move Daily Files**
   - Move all matching daily files from `daily/` to the archive directory
   - Preserve backlinks exactly as they are

5. **Generate Summary File**
   - Create `archive/{year}_{month}/summary.md`
   - Read all archived daily files to extract:
     - Overall narrative summary (3-5 sentences)
     - Key accomplishments ([COMPLETED] entries)
     - Active projects (unique [[Project]] backlinks from `projects/` references)
     - Collaborations (unique [[Person]] backlinks from `people/` references)
     - Notable challenges (from context)
   - Calculate statistics:
     - Total entries count
     - Working days logged count
     - Project activity (mention counts per project)
     - Collaboration frequency (interaction counts per person)

6. **Confirm Completion**
   - Report: files moved, summary created, archive location

## Summary Template

Generate the summary file using this structure:

```markdown
# {Month} {Year} Summary

## Overview
[AI-generated 3-5 sentence summary of the month's work]

## Key Accomplishments
- [Major completed items extracted from [COMPLETED] entries]

## Active Projects
- [[Project1]] - status/context notes
- [[Project2]] - status/context notes

## Collaborations
- [[Person1]], [[Person2]], etc.

## Notable Challenges
- [Significant challenges or context worth remembering]

## Daily Entries
- 2026-01-02.md
- 2026-01-03.md
- ...

## Statistics

| Metric | Count |
|--------|-------|
| Total Entries | X |
| Working Days Logged | X |

### Project Activity
| Project | Mentions |
|---------|----------|
| [[Project1]] | X |
| [[Project2]] | X |

### Collaboration Frequency
| Person | Interactions |
|--------|--------------|
| [[Person1]] | X |
| [[Person2]] | X |
```

## Chronos Directory

All chronos files live in `/Users/jacob.waldrip/Development/chronos/`.

## Important Notes

- This command is designed to work with the Note Squire agent (`agent/note-squire.md`)
- Backlinks are preserved for Obsidian compatibility
- Files are **moved**, not copied - originals will no longer exist in `daily/`
- The archive is searchable by the Note Squire for historical queries
- Month names should be lowercase in folder names (e.g., `2026_january`, not `2026_January`)
