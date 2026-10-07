# Axle Health API - Standard Workflows

## Creating a Visit (End-to-End)

The standard workflow for creating a visit in Axle:

### Step 1: Coverage Lookup

Determine which service areas cover the patient's location:

```typescript
const coverage = await axle.getCoverageLookup({ address: patientAddress });
// or: getCoverageLookup({ zipcode: '10001' })
// or: getCoverageLookup({ clinic_id: 'clinic-uuid' })

// Returns: { service_areas: ServiceArea[] }
// Each service area includes available services and service bundles
```

### Step 2: Generate Potential Visit from Service Bundle

Use a service bundle to generate a visit template:

```typescript
const { potential_visit } = await axle.getPotentialVisitFromServiceBundle({
  address: patientAddress,
  patient_id: 'patient-uuid',
  service_area_id: 'service-area-uuid',       // from coverage lookup
  service_bundle_id: 'service-bundle-uuid',   // from coverage lookup
});
```

This returns a `PotentialVisit` with pre-configured clinician appointments, encounters, duration, etc.

### Step 3: Find Available Time Slots

```typescript
const { recommended_time_options } = await axle.getVisitTimeOptionsForNewVisit({
  potential_visit,
  search_window: {
    start_datetime: '2024-01-15T08:00:00Z',
    end_datetime: '2024-01-19T17:00:00Z',
  },
  clinician_filters: [],  // optional: restrict to specific clinicians
});
```

**Important**: `search_window.end_datetime` must be after `start_datetime` (validated by client).

### Step 4: Get Clinician Recommendations

For a specific time slot:

```typescript
const { clinician_options } = await axle.getClinicianOptionsForPotentialVisitAtProposedTime({
  potential_visit,
  potential_start_datetime: '2024-01-15T09:00:00Z',
  clinician_filters: [],
});

// Each option: { clinician_appointment_id, recommended_clinicians: [{ clinician_id }] }
```

Or over a date range (returns eligible, not availability-filtered):

```typescript
const { clinician_options } = await axle.getClinicianOptionsForPotentialVisitOverDateRange({
  potential_visit,
  search_window: { start_datetime: '...', end_datetime: '...' },
  clinician_filters: [],
});
// Each option: { clinician_appointment_id, eligible_clinicians: [{ clinician_id }] }
```

### Step 5: (Optional) Reserve Clinician Time

Hold clinician schedules while confirming with the patient:

```typescript
const { visit_reservation_id } = await axle.createVisitReservation({
  potential_visit,
  expiry_datetime: '2024-01-15T10:00:00Z',  // reservation expires at this time
});

// Later, if not booking:
await axle.deleteVisitReservation(visit_reservation_id);
```

### Step 6: Create the Visit

**Scheduled visit** (with a specific time):

```typescript
const { visit_id } = await axle.createVisit({
  ...potential_visit,
  clinician_appointments: potential_visit.clinician_appointments.map(ca => ({
    ...ca,
    clinician_id: selectedClinicianId,  // assign clinician
  })),
  patient_appointments: [{ patient_id: 'patient-uuid', patient_confirmation_status: 'NONE', contact: null }],
  start_datetime: '2024-01-15T09:00:00Z',
  visit_reservation_id,  // optional, if using reservations
  metadata: { source: 'scheduling-service' },
  priority: 'STANDARD',
});
```

**Unscheduled visit** (with timeslot preferences):

```typescript
const { visit_id } = await axle.createVisit({
  ...potential_visit,
  clinician_appointments: [...],
  patient_appointments: [...],
  start_datetime: null,
  timeslot_preferences: {
    preferred_windows: [
      { start_datetime: '2024-01-15T08:00:00Z', end_datetime: '2024-01-15T12:00:00Z' },
    ],
  },
});
```

**Note**: `skip_validation: { skip_everything: true }` can bypass validation rules (use cautiously).

## Editing a Visit

```typescript
await axle.editVisitById(visitId, {
  // Top-level fields (all optional)
  summary_status: 'CONFIRMED',
  start_datetime: '2024-01-16T10:00:00Z',
  address: newAddress,
  priority: 'HIGH',
  metadata: { updated_by: 'system' },

  // Clinician appointment changes
  clinician_appointments_to_edit: [{
    clinician_appointment_id: 'ca-uuid',
    clinician_id: 'new-clinician-uuid',
    clinician_appointment_status: 'NOT_STARTED',
    start_offset_minutes: 0,
    duration_override_minutes: null,
  }],
  clinician_appointments_to_delete: [{ clinician_appointment_id: 'ca-to-remove' }],

  // Encounter changes
  encounters_to_add: [{ clinician_appointment_id: 'ca-uuid', patient_id: 'p-uuid', services: [{ service_id: 'svc-uuid' }] }],
});
```

## Rescheduling a Visit

```typescript
// 1. Get new time options
const { recommended_time_options } = await axle.getVisitTimeOptionsForExistingVisit({
  visit_id: visitId,
  search_window: { start_datetime: '...', end_datetime: '...' },
});

// 2. Get clinician options at the new time
const { clinician_options } = await axle.getClinicianOptionsForExistingVisits({
  visit_id: visitId,
});

// 3. Apply the reschedule
await axle.editVisitById(visitId, {
  start_datetime: recommended_time_options[0].start_datetime,
  clinician_appointments_to_edit: [...],
});
```

## Canceling a Visit

```typescript
await axle.editVisitById(visitId, {
  summary_status: 'CANCELED',
});
```

## Webhook Processing Flow

Axle sends webhooks when visits change. The processing pipeline:

```
Axle Health --> POST webhook --> axle-visit-webhook-v2stable (Cloud Function)
                                  |
                                  | 1. Validate Axle-Signature (HMAC-SHA256)
                                  | 2. Publish to PubSub topic
                                  v
                          axleVisitWebhookNotificationsV2Stable (PubSub)
                                  |
                                  v
                          transform-axle-to-fhir-v2stable (Cloud Function)
                                  |
                                  | 1. Transform visit data to FHIR bundle
                                  | 2. Publish to transformedAxleAppointments topic
                                  v
                          create-sync-to-fhir-store-from-axle-task (Cloud Function)
                                  |
                                  | Creates a Cloud Task
                                  v
                          scheduling-service /sync/axle (Cloud Run)
                                  |
                                  | axle-to-fhir-store.controller.ts
                                  | 1. Acquire distributed lock (AxleSyncTransaction)
                                  | 2. Reconcile with existing FHIR data
                                  | 3. Write to FHIR Store
                                  | 4. Release lock
```

### Webhook Signature Verification

```typescript
// Header format: "t=<timestamp>,v1=<signature>"
const { timestamp, signature } = getTimestampAndSignatures(headers['axle-signature']);

const message = `${timestamp}.${rawBody}`;
const expected = crypto.createHmac('sha256', webhookSecret).update(message).digest('hex');

const valid = crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
```

Implementation: `cloud_functions/axle-visit-webhook-v2stable/src/index.ts`

### Webhook Payload Shape

```typescript
{
  triggering_location: 'DASHBOARD' | 'API' | 'CLINICIAN_APP' | 'PATIENT_PORTAL' | 'AXLE_SYSTEM',
  type: 'visit',       // currently only 'visit' is processed; 'shift' is logged but ignored
  updated_at: string,  // ISO-8601
  visit: VisitFull     // complete visit object
}
```

## Bidirectional Sync (FHIR Store <-> Axle)

The system maintains a bidirectional sync between Axle visits and the Google Healthcare FHIR Store:

### Axle -> FHIR Store

1. Webhook triggers the pipeline above
2. Controller: `axle-to-fhir-store.controller.ts`
3. Services: `scheduling-service/server/services/fhir-store/axle/`
4. Transforms Axle visit data into FHIR Appointment, Patient, Practitioner, Location, Slot, and Schedule resources

### FHIR Store -> Axle

1. FHIR Store publishes notifications on changes
2. Cloud Function creates a Cloud Task
3. Controller: `fhir-store-to-axle.controller.ts`
4. Services: `scheduling-service/server/services/axle/sync/`
5. Transforms FHIR data back to Axle format and calls `editVisitById`

### Distributed Locking

Both sync directions use locking to prevent conflicts:

- **`AxleSyncTransaction`** model: Locks on Axle visit ID during sync operations
- **`AppointmentAxleSync`** model: Tracks last sync timestamps for each appointment
- Retry logic: Up to 8 attempts with random 2-5 second intervals
- Implementation: `scheduling-service/server/helpers/retry-sync.ts`

### Sync Filtering

Not all appointments sync to Axle. The sync filter (`scheduling-service/server/helpers/sync-filters.helper.ts`) determines whether an appointment is "Axle-eligible" based on service area mappings and other criteria.

## Config Caching

Axle configuration (service areas, appointment types, locations) is cached for performance:

- Controller: `config-from-axle.controller.ts`
- Service: `scheduling-service/server/services/config/axle-config.service.ts`
- Storage: GCS bucket `cbh-axle-data-{env}` with `service-areas.json`
- Uses fuzzy matching for location/appointment type resolution
- See: `scheduling-service/server/services/config/axle-config-helpers.ts`

## Managing Clinician Workforce

### Create a Clinician

```typescript
const clinician = await axle.createClinician({
  first_name: 'Jane',
  last_name: 'Doe',
  email: 'jane.doe@example.com',
  phone: '+14155551234',
  default_shift_options: {
    mobile_territories: [{ territory_id: 'territory-uuid' }],
    virtual_territories: [],
  },
  qualifications: [{ qualification_id: 'qual-uuid' }],
});
```

### Create a Shift (Availability)

```typescript
const shift = await axle.createShift({
  clinician_id: 'clinician-uuid',
  start_datetime: '2024-01-15T08:00:00-05:00',
  end_datetime: '2024-01-15T17:00:00-05:00',
  time_zone: 'America/New_York',
  rrule: 'FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',  // recurring weekdays
  exclude_datetimes: [],
  mobile_territories: [{ territory_id: 'territory-uuid' }],
  virtual_territories: [],
  clinic_ids: null,
});
```

### Block Off Time (Shift Block)

```typescript
const block = await axle.createShiftBlock({
  clinicians: [{ clinician_id: 'clinician-uuid' }],
  timezone: 'America/New_York',
  start_datetime: '2024-01-15T12:00:00-05:00',
  end_datetime: '2024-01-15T13:00:00-05:00',
  recurrence: null,       // one-time block
  start_address: null,
  notes: 'Lunch break',
});
```
