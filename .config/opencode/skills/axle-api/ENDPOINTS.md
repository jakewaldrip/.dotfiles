# Axle Health API - Endpoint Reference

All endpoints use base URL `{baseAxleUrl}/v2-stable/`. Authentication via `Authorization: Bearer <token>`.

The `@cityblock/axle` client methods are listed alongside each endpoint. See `packages/axle/src/axle-client.ts` for implementation.

## Patients

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `patients` | `createPatient(input: PatientInput)` | Create a patient. Returns `{ patient_id }` |
| `GET` | `patients/{id}` | `getPatientById(id)` | Get full patient details |
| `PATCH` | `patients/{id}` | `updatePatient(id, input: PatientEditInput)` | Edit patient. Only provided fields updated |

## Clinicians

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `clinicians` | `createClinician(input: ClinicianInput)` | Create a clinician |
| `GET` | `clinicians` | `getClinicians(offset?, countLimit?)` | Paginated list. Also: `getAllClinicians()` |
| `GET` | `clinicians/{id}` | `getClinicianById(id)` | Get full clinician details |
| `PATCH` | `clinicians/{id}` | `updateClinician(id, input: ClinicianUpdateInput)` | Edit clinician |

## Territories

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `territories` | `createTerritory(input: TerritoryInput)` | Create a territory |
| `GET` | `territories` | `getTerritories(offset?, countLimit?)` | Paginated list (summaries only, no zip codes). Also: `getAllTerritories()` |
| `GET` | `territories/{id}` | `getTerritoryById(id)` | Get full territory details **including zip codes** |
| `PATCH` | `territories/{id}` | `updateTerritory(id, input: TerritoryUpdate)` | Edit territory |

**Note**: `getAllTerritories()` fetches full details (including zip codes) for each territory by calling `getTerritoryById` per item.

## Qualifications

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `qualifications` | `createQualification(input: QualificationInput)` | Create a qualification |
| `GET` | `qualifications` | `getQualifications(offset?, countLimit?)` | Paginated list. Also: `getAllQualifications()` |
| `GET` | `qualifications/{id}` | `getQualificationById(id)` | Get qualification by ID |
| `PATCH` | `qualifications/{id}` | `updateQualification(id, input: QualificationInput)` | Edit qualification |
| `DELETE` | `qualifications/{id}` | `deleteQualification(id)` | Delete qualification (also removes from services/clinicians) |

## Shifts

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `shifts` | `createShift(input: ShiftInput)` | Create a shift for a clinician |
| `GET` | `shifts` | `getShifts(offset?, countLimit?)` | Paginated list. Also: `getAllShifts()` |
| `GET` | `shifts/{id}` | `getShiftById(id)` | Get shift details |
| `PATCH` | `shifts/{id}` | `updateShift(id, input: ShiftUpdateInput)` | Edit shift |

**Not yet in client** (available in API):
- `DELETE shifts/{id}` - Cancel a shift

**Instance endpoints** (not yet in client):
- `GET shift-instances` - List shift instances within a time window (expands recurring shifts)

## Shift Blocks

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `shift-blocks` | `createShiftBlock(input: ShiftBlockInput)` | Create a shift block (unavailability) |
| `GET` | `shift-blocks` | `getShiftBlocks(offset?, countLimit?)` | Paginated list. Also: `getAllShiftBlocks()` |
| `GET` | `shift-blocks/{id}` | `getShiftBlockById(id)` | Get shift block details |
| `PATCH` | `shift-blocks/{id}` | `updateShiftBlock(id, input: ShiftBlockUpdateInput)` | Edit shift block (limited fields: start/end datetime only) |
| `DELETE` | `shift-blocks/{id}` | `deleteShiftBlock(id)` | Delete all instances of shift block |

**Instance endpoints** (not yet in client):
- `GET shift-block-instances` - List shift block instances within a time window

## Services

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `GET` | `services` | `getServices(offset?, countLimit?)` | Paginated list. Also: `getAllServices()` |

**Not yet in client** (available in API):
- `POST services` - Create a service
- `GET services/{id}` - Get service details
- `PATCH services/{id}` - Edit a service

## Service Bundles

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `GET` | `service-bundles` | `getServiceBundles(offset?, countLimit?)` | Paginated list. Also: `getAllServiceBundles()` |

**Not yet in client** (available in API):
- `POST service-bundles` - Create a service bundle
- `GET service-bundles/{id}` - Get service bundle details
- `PATCH service-bundles/{id}` - Edit a service bundle

## Visits

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `visits` | `createVisit(input: CreateVisitInput)` | Create a visit (scheduled or unscheduled) |
| `GET` | `visits/{id}` | `getVisitById(id)` | Get full visit details |
| `PATCH` | `visits/{id}` | `editVisitById(id, input: EditVisitInput)` | Edit visit. Returns validation results |

**Not yet in client** (available in API):
- `GET visits` (with date range filters) - List visits

## Visit Scheduling Helpers

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `visit-time-options/potential-visit` | `getVisitTimeOptionsForNewVisit(input)` | Get available time slots for a new visit |
| `POST` | `visit-time-options/existing-visit` | `getVisitTimeOptionsForExistingVisit(input)` | Get reschedule time slots for existing visit |
| `POST` | `clinician-options/potential-visit/proposed-time` | `getClinicianOptionsForPotentialVisitAtProposedTime(input)` | Get recommended clinicians at a specific time |
| `POST` | `clinician-options/existing-visit` | `getClinicianOptionsForExistingVisits(input)` | Get clinician options for an existing visit |
| `POST` | `clinician-options/potential-visit/date-range` | `getClinicianOptionsForPotentialVisitOverDateRange(input)` | Get eligible clinicians over a date range |
| `POST` | `generate-potential-visit-from-service-bundle` | `getPotentialVisitFromServiceBundle(input)` | Generate a visit template from a service bundle |

## Coverage

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `coverage-lookup` | `getCoverageLookup(input: CoverageLookupInput)` | Find service areas covering an address, zip code, or clinic |

Input can be one of:
- `{ address: Address }` - Lookup by full address
- `{ zipcode: string }` - Lookup by zip code
- `{ clinic_id: string }` - Lookup by clinic ID

Returns `{ service_areas: ServiceArea[] }` with available services and service bundles.

## Visit Requests

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `visit-requests` | `createVisitRequest(input: VisitRequestInput)` | Create a visit request. Returns `{ visit_request_id }` |
| `GET` | `visit-requests/{id}` | `getVisitRequestById(id)` | Get visit request details |
| `PATCH` | `visit-requests/{id}` | `updateVisitRequest(id, input: VisitRequestUpdateInput)` | Update visit request |

## Visit Reservations

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `visit-reservations` | `createVisitReservation(input: VisitReservationInput)` | Hold clinician schedules for an upcoming visit |
| `DELETE` | `visit-reservations/{id}` | `deleteVisitReservation(id)` | Release the hold |

## Care Teams

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `care-teams` | `createCareTeam(input: CareTeamInput)` | Create a care team |
| `GET` | `care-teams` | `getCareTeams(offset?, countLimit?)` | Paginated list |
| `GET` | `care-teams/{id}` | `getCareTeamById(id)` | Get care team details |
| `PATCH` | `care-teams/{id}` | `updateCareTeam(id, input: CareTeamUpdateInput)` | Edit care team |

## Payers

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `GET` | `payers` | `getPayers(offset?, countLimit?)` | Paginated list. Also: `getAllPayers()` |

## Documents

| Method | Path | Client Method | Description |
|--------|------|---------------|-------------|
| `POST` | `docs/{id}/generate-download-link` | `generateDocumentDownloadLink(id)` | Get a temporary download URL for a document |

## Pagination Pattern

All list endpoints use offset-based pagination:

```typescript
// Manual pagination
const { items, pagination } = await axle.getClinicians(offset, countLimit);
// pagination = { offset: 0, count_limit: 100, total_records: 250 }

// Auto-pagination (fetches all pages)
const allClinicians = await axle.getAllClinicians();
```

Default `count_limit` is 100 (`DEFAULT_COUNT_LIMIT` in the client).

## Error Handling Pattern

All client methods follow this pattern:
```typescript
try {
  const { data } = await this.v2Client.post<OutputType>('endpoint', input);
  return data;
} catch (error: any) {
  const errorMessage = 'Error doing X';
  this.logAxiosError(errorMessage, error);
  throw error; // or throw error.response.data for some endpoints
}
```

**Important**: Some endpoints throw `error.response.data` (visit/scheduling endpoints) while others throw the raw `error`. Check the specific method in `axle-client.ts` for exact behavior.
