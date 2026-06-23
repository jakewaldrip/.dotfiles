# ENG-2209: Scheduling Playbook & Provider Directory Links — Decisions & Scope

## Overview

Add two UI entry points to the scheduling workflow's header area: one that opens the Scheduling Playbook (NotebookLM) in a new tab, and one that opens the existing provider directory (from ENG-2079) in a modal. Both are gated behind the `centralSchedulingContext` feature flag.

---

## Decisions

| #   | Decision                    | Choice                                                                          | Rationale                                                                                                                                                                                                                                                                                                                 |
| --- | --------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | **Button placement**        | `actions` prop on the `<Layout>` wrapping the scheduling page                   | The `SectionHeader` component renders actions in a `<Row>` in the upper-right, matching the screenshot annotation. Currently no actions exist on this page.                                                                                                                                                               |
| 2   | **Button style**            | Two icon-only buttons with tooltips                                             | Compact presentation; avoids crowding the header. `menuBook` icon for playbook, `people` icon for directory. Storybook guidance allows up to 3 icon buttons in a header; we use 2.                                                                                                                                        |
| 3   | **Icons**                   | `menuBook` (Scheduling Playbook) + `people` (Provider Directory)                | `menuBook` = MUI `MenuBookRounded` (open book), `people` = MUI `PeopleRounded` (two people). Clear and distinct visual cues. Tooltip text provides labels on hover via `isIconOnly` + `text` prop pattern.                                                                                                                |
| 4   | **Eligible/Other split**    | Two separate GraphQL queries, client-side dedup                                 | Frontend fires one query filtered by patient market + partner ("eligible"), one unfiltered for all. Client deduplicates to produce the "other" set. No backend changes needed — existing `ProviderProfileFilterInput` already supports `marketId` and `partnerId`.                                                        |
| 5   | **Modal variant**           | New `ProviderDirectoryModal` component wrapping a tailored version of the table | The existing `ProviderDirectoryContainerUI` is tightly coupled to full-page `<Layout>` and `useNavigate()`. Rather than making the existing components modal-aware, create a dedicated modal component that reuses the data-fetching hooks and GraphQL queries but renders inside a `<Modal size="extraLarge" isDocked>`. |
| 6   | **Modal sections**          | Tabs: "Eligible" and "All Providers"                                            | Two tabs using `TabRow` + `Tab` from Commonplace inside the modal body. Only one list visible at a time. Cleaner than stacking two tables. The "Eligible" tab is pre-filtered by patient market + partner; "All Providers" shows the full directory.                                                                      |
| 7   | **Row click behavior**      | `TableV2` with detail sub-panel below the table                                 | `TableV2` does not support native expandable rows. Clicking a row shows/hides a detail panel below the table (within the same tab). Row stays highlighted. Avoids losing table column alignment. Proven modal-interior pattern (e.g., quality modal).                                                                     |
| 8   | **Modal table columns**     | Reduced: Name + Markets + Specialty (3 columns)                                 | Modal max-width is 880px at `extraLarge`. Full directory shows 5 columns which would be cramped. Hubs and status details appear in the detail sub-panel on row click.                                                                                                                                                     |
| 9   | **Admin features in modal** | Read-only only                                                                  | Modal is purely for lookup during scheduling. No create/edit/deactivate/status-filter. Users go to `/provider-directory` for admin tasks.                                                                                                                                                                                 |
| 10  | **Filter UI in modal**      | No filter controls — name search only                                           | The "Eligible" tab pre-filters by patient market + partner, covering the primary scheduling use case. Advanced filtering (specialty, gender, hub, etc.) is available on the full-page directory at `/provider-directory`. Keeps the modal focused and simple.                                                             |
| 11  | **Detail sub-panel data**   | No extra fetch — reuse list query data                                          | The list query (`GetProviderProfiles`) fetches identical fields to the detail query. All sub-panel fields are already available in the loaded list item. Pass the row data directly to the sub-panel component.                                                                                                           |
| 12  | **Partner ID source**       | `patient.partnerV2.id` (already in query)                                       | The `GetPatientForProfileContainerQuery` already fetches `partnerV2 { id }` at line 538. No additional query or backend changes needed. Fallback: `patient.activeEnrollments[0].partner.id`.                                                                                                                              |
| 13  | **Empty tab behavior**      | Always show both tabs; render `<Empty>` in the panel                            | Follows established codebase convention (`service-plan.tsx` Active/Archived tabs pattern). Tabs are never hidden based on empty data.                                                                                                                                                                                     |
| 14  | **Feature flag**            | Reuse existing `FeatureFlags.centralSchedulingContext`                          | Already used in the scheduling workflow and provider directory. Both buttons render only when this flag is enabled.                                                                                                                                                                                                       |

---

## Key Architecture Notes

### Where the buttons go

The scheduling page is rendered at:

```
/members/:patientId/appointments/schedule/...
```

Defined in `patient-profile-container.tsx:445-451`:

```tsx
<Layout title={{ id: 'appointmentWorkflow.scheduleAppointment' }}>
  <AppointmentWorkflow patient={patient} />
</Layout>
```

The `Layout` component delegates to `SectionHeader`, which renders an `actions` slot in the upper-right of the header. We add the two icon buttons via this prop.

### Icon button implementation

```tsx
<Button
  icon="menuBook"
  isIconOnly
  text={{ id: 'schedulingWorkflow.playbook' }}  // tooltip on hover
  onClick={() => window.open('https://notebooklm.google.com/notebook/...', '_blank')}
/>
<Button
  icon="people"
  isIconOnly
  text={{ id: 'schedulingWorkflow.providerDirectory' }}  // tooltip on hover
  onClick={() => setIsDirectoryModalOpen(true)}
/>
```

### Provider directory modal: what needs to change

The existing provider directory components (`ProviderDirectoryTable`, `ProviderDirectoryContainerUI`) have these modal-incompatible dependencies:

| Dependency                                           | Issue                            | Resolution                                                            |
| ---------------------------------------------------- | -------------------------------- | --------------------------------------------------------------------- |
| `<Layout scroll="all" title=...>` wrapper            | Full-page layout primitive       | Modal variant omits this; content goes directly in `<Modal>` children |
| `useNavigate()` in table for row clicks              | Routes away from scheduling page | Replace with detail sub-panel toggle                                  |
| `<Link to="/provider-directory/:id">` in name column | Navigates to detail page         | Replace with plain text; row click opens detail sub-panel             |
| "New Profile" button (`Can I="create"`)              | Admin-only create navigation     | Omit from modal variant                                               |
| Status filter (`Can I="update"`)                     | Admin-only filter                | Omit from modal variant                                               |

### Modal layout (wireframe)

```
+--------------------------------------------------+
| Provider Directory                         [X]   |
+--------------------------------------------------+
| [Search by name.............................]     |
|                                                   |
| [Eligible] [All Providers]    <- TabRow           |
|                                                   |
| +----------------------------------------------+ |
| | Name          | Markets      | Specialty      | |  <- TableV2 (3 columns)
| |---------------|--------------|----------------| |
| | Smith, Jane   | NYC, NC      | Physical Health| |
| | Doe, John     | Ohio         | Pediatrics     | |  <- Click row to select
| +----------------------------------------------+ |
|                                                   |
| +----------------------------------------------+ |  <- Detail sub-panel (shown on row click)
| | Jane Smith, MD                                | |
| | Specialties: Physical Health, Pregnancy       | |
| | Hubs: NYC Downtown, NYC Midtown               | |
| | Credentials: NYC: Healthy Blue, AmeriHealth   | |
| | Languages: English, Spanish                   | |
| | States: NY, NJ, CT                            | |
| | Gender: Female                                | |
| +----------------------------------------------+ |
+--------------------------------------------------+
```

### Tab behavior

- **Eligible tab**: Pre-filtered query with `{ marketId: patient.market.id, partnerId: <resolved>, status: 'Active' }`. Shows only providers matching the current patient's market and partner.
- **All Providers tab**: Unfiltered query with `{ status: 'Active' }`. Shows the full active directory.
- Name search is shared across both tabs (applied to whichever is active). No filter dropdowns.
- Switching tabs clears the selected row / hides the detail sub-panel.

### Patient context available

At the route level, the `patient` object (from `GetPatientForProfileContainerQuery`) is available and contains:

- `patient.market.id` / `patient.market.name` — for market filtering
- `patient.partnerV2.id` — partner UUID, already fetched in the query (line 538-540)
- `patient.activeEnrollments[0].partner.id` — fallback partner UUID if `partnerV2` is null

**Resolved:** The `patient.partnerV2.id` field provides the partner UUID directly. No additional lookup or backend changes needed. The `currentEligibility.partner` field is a name-only string and should NOT be used for filtering.

---

## Scope

### In scope

- Two icon buttons in the scheduling page header (upper-right): `menuBook` + `people`
- Playbook button: opens NotebookLM link (`https://notebooklm.google.com/notebook/ecf2220a-fcfe-42ca-b028-f64cc69f022f`) in a new tab
- Provider directory button: opens a modal with the provider directory
- Modal with two tabs: "Eligible" (filtered by patient market + partner) and "All Providers"
- `TableV2` with 3 columns (Name, Markets, Specialty) per tab
- Detail sub-panel below the table on row click (specialties, hubs, credentials, languages, states, gender)
- Name search within the modal (shared across tabs; no filter dropdowns)
- Feature flag gated (`centralSchedulingContext`)
- i18n message keys for button tooltips, tab labels, section headers

### Out of scope

- Admin features (create/edit/deactivate) inside the modal
- Refactoring the existing full-page provider directory components for reuse (we create a parallel modal variant)
- Provider matching/assignment logic
- Any backend GraphQL changes (existing queries and filters suffice)
- Changes to the full-page provider directory

---

## Component Plan (High Level)

```
patient-profile-container.tsx
  Layout (actions={<SchedulingWorkflowActions />})
    |- PlaybookButton (icon="menuBook", isIconOnly -> window.open)
    |- DirectoryButton (icon="people", isIconOnly -> opens modal)
         |- ProviderDirectoryModal (Modal size="extraLarge" isDocked)
               |- Search bar (name search only)
               |- TabRow
              |    |- Tab: "Eligible"
              |    |- Tab: "All Providers"
              |- ProviderDirectoryModalTable (TableV2, 3 columns: Name, Markets, Specialty)
              |- ProviderDetailSubPanel (shown below table on row click, no extra fetch needed)
```

### New files (estimated)

| File                                 | Purpose                                                   |
| ------------------------------------ | --------------------------------------------------------- |
| `scheduling-workflow-actions.tsx`    | Two icon buttons component, rendered in Layout actions    |
| `provider-directory-modal.tsx`       | Modal shell with tabs, name search, data fetching         |
| `provider-directory-modal-table.tsx` | Simplified TableV2 (3 columns, no nav, row click selects) |
| `provider-detail-sub-panel.tsx`      | Detail panel shown below table when a row is clicked      |

### Modified files (estimated)

| File                            | Change                                                     |
| ------------------------------- | ---------------------------------------------------------- |
| `patient-profile-container.tsx` | Pass `actions` prop to `<Layout>` for the scheduling route |

---

## Resolved Questions

### 1. Partner ID resolution — RESOLVED

The `patient.partnerV2.id` field already provides the partner UUID directly in the `GetPatientForProfileContainerQuery` response (query line 538-540). No additional lookup, query changes, or backend modifications needed.

```ts
const partnerId = patient.partnerV2?.id; // primary source
const fallbackPartnerId = patient.activeEnrollments?.[0]?.partner?.id; // fallback
```

### 2. Detail sub-panel fields — RESOLVED

The list query (`GetProviderProfiles`) already fetches **every field** the detail view uses — the field selections are identical between the list and detail queries. No additional network fetch is needed for the sub-panel. Pass the already-loaded list item directly into the sub-panel component.

**Sub-panel fields (all available from list query data):**

| Section           | Fields                                                                         |
| ----------------- | ------------------------------------------------------------------------------ |
| **User Info**     | Name (firstName + lastName), Email, NPI                                        |
| **Clinical**      | Clinical specialties, Other specializations, Specialization notes              |
| **Location**      | Markets, Hubs, Base zip code, Location notes                                   |
| **Credentialing** | Credentials grouped by market ("NYC: Healthy Blue, AmeriHealth \| OH: Anthem") |
| **Demographics**  | Gender, Languages spoken                                                       |
| **Status**        | Active/Inactive tag                                                            |

Audit info (created/updated by/at) can be omitted from the sub-panel to keep it compact — it's less relevant during scheduling lookup.

### 3. Empty states — RESOLVED

Follow the established codebase pattern: **always show both tabs, render `<Empty>` inside the empty tab's panel.**

- "Eligible" tab with no results: Show `<Empty icon="people" title="No eligible providers found" description="No providers match this member's market and partner.">` inside the tab panel.
- Do NOT hide the tab or auto-switch. The `service-plan.tsx` pattern (LTSS Active/Archived tabs) demonstrates this convention.
- "All Providers" tab empty (after filtering/search): Show `<Empty icon="people" title="No providers found">` via `TableV2`'s `emptyContent` prop.

### 4. Filter panel in modal — RESOLVED (removed)

No filter controls in the modal. The "Eligible" tab pre-filters by patient market + partner, which is the primary lookup during scheduling. The "All Providers" tab provides the full directory. Name search is sufficient for finding specific providers. Users needing advanced filtering should use the full-page directory at `/provider-directory`.

This also avoids the `FilterPanel` z-index conflict (`FilterPanel` at z-index 13 vs Modal backdrop at z-index 99) and reduces component complexity.
