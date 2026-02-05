---
description: Start your work day by creating today's log and reviewing carry-over items
---

# Start Day

Creates today's daily log file, reviews incomplete work from previous sessions, and provides context to help you start your day.

## Usage

```
/start-day
```

No arguments required.

## Execution Steps

1. **Time-Aware Greeting**
   - Before 12:00 PM: "Good morning!"
   - 12:00 PM - 5:00 PM: "Good afternoon!"
   - After 5:00 PM: "Good evening!"

2. **Check/Create Today's File**
   - Check if today's file exists at `daily/YYYY-MM-DD.md`
   - If it exists, note this and skip creation
   - If not, create it with the daily template:
     ```markdown
     # YYYY-MM-DD

     ## Carry-over
     <!-- Items carried from previous day as regular entries -->

     ## TODO
     <!-- Planned tasks for today - move to Log when started -->

     ## Log
     <!-- New entries go here -->
     ```

3. **Find Most Recent Previous Log**
   - Scan `daily/` for the most recent file before today's date
   - This handles weekends, vacations, and gaps in logging
   - If no previous file exists, skip carry-over step

4. **Identify Incomplete Items**
   - From the most recent file, find entries that are incomplete:
     - `[WORKING]` entries without a corresponding `[COMPLETED]` for the same task
     - `[BLOCKED]` entries (still blocked unless explicitly resolved)
     - `[TODO]` entries that were never started
   - Present these as numbered carry-over candidates

5. **Ask for Carry-over Selection**
   - Present the incomplete items to the user
   - Accept responses: "all", "none", or comma-separated numbers (e.g., "1, 3")
   - Add selected items to today's Carry-over section

6. **Project Status Check**
   - Scan `projects/` directory for all project files (excluding `_template.md`)
   - For each project, check recent `daily/` files (last 7 days) for mentions
   - Categorize projects:
     - **Active**: Mentioned in the last 3 days
     - **Quiet**: Not mentioned in 4-7 days (worth a reminder)
     - **Dormant**: Not mentioned in 7+ days (may need attention)
   - Only report "Quiet" projects as a gentle nudge (don't overwhelm)

7. **Archive Awareness**
   - Check if it's a new month (today is day 1-7 of the month)
   - Check if previous month's files still exist in `daily/`
   - If yes, remind user: "Note: [Previous month]'s daily logs haven't been archived yet. Run `/end-month` when ready."

8. **Confirmation Output**
   - Summarize what was done
   - Show the carry-over items added (if any)
   - Show quiet projects (if any)
   - Show archive reminder (if applicable)
   - Indicate the day is ready for logging

## Example Output

```
Good morning! I've created today's log (2026-02-03.md).

From your last session (2026-01-30), I found these incomplete items:
1. [WORKING] [[BrazeMigration]] - API integration
2. [BLOCKED] Waiting on API keys from [[MikeJohnson]]
3. [TODO] Review PR for [[TaskLabelRefactor]]

Which would you like to carry over? (all / none / numbers)
```

---

After user responds "1, 3":

```
Carried over 2 items to today's log.

**Quiet Projects** (no activity in 4-7 days):
- [[BOIConditionsCache]] - last mentioned 5 days ago

**Reminder**: January's daily logs haven't been archived yet. Run `/end-month` when ready.

Ready to log! What are you working on?
```

## Chronos Directory

All chronos files live in `/Users/jacob.waldrip/Development/chronos/`.

## Important Notes

- This command is designed to work with the Note Squire agent (`agent/note-squire.md`)
- Can also be triggered via natural language ("start my day", "good morning", etc.)
- The "most recent file" logic handles gaps from weekends, sick days, or vacations
- Project status only shows "quiet" projects to avoid overwhelming the user
- Archive reminder only appears in the first week of a new month
