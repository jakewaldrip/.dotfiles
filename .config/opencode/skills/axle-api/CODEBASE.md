# Axle Health API - Codebase Reference

How the Axle Health integration is structured within `cbh-scheduling`.

## Architecture Diagram

```
                        ┌──────────────────────┐
                        │   Axle Health API     │
                        │  (axlehealth.com)     │
                        └──────┬───────┬────────┘
                               │       │
                     Webhooks  │       │  REST API (v2-stable)
                     (HMAC)    │       │  (Bearer token auth)
                               ▼       ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     GCP (cbh-scheduling-*)                           │
│                                                                      │
│  ┌─────────────────────┐       ┌──────────────────────────────┐     │
│  │ axle-visit-webhook   │       │  @cityblock/axle package     │     │
│  │ (Cloud Function)     │       │  (axios-based SDK client)    │     │
│  │ Validates signature  │       │  Used by scheduling-service  │     │
│  └──────────┬──────────┘       └──────────────────────────────┘     │
│             │                                                        │
│             ▼                                                        │
│  ┌──────────────────────┐                                           │
│  │ PubSub: axleVisit     │                                           │
│  │ WebhookNotifications  │                                           │
│  │ V2Stable              │                                           │
│  └──────────┬───────────┘                                           │
│             ▼                                                        │
│  ┌──────────────────────────┐                                       │
│  │ transform-axle-to-fhir   │                                       │
│  │ (Cloud Function)          │──▶ GCS (raw FHIR bundles)             │
│  └──────────┬───────────────┘                                       │
│             ▼                                                        │
│  ┌──────────────────────────┐                                       │
│  │ PubSub: transformedAxle   │                                       │
│  │ Appointments              │                                       │
│  └──────────┬───────────────┘                                       │
│             ▼                                                        │
│  ┌────────────────────────────┐  ┌────────────────────────────────┐ │
│  │ create-sync-to-fhir-store- │  │ create-sync-to-axle-from-     │ │
│  │ from-axle-task             │  │ fhir-store-task                │ │
│  │ (Cloud Function ▶ Task)    │  │ (Cloud Function ▶ Task)        │ │
│  └──────────┬─────────────────┘  └──────────┬─────────────────────┘ │
│             │                                │                       │
│             ▼                                ▼                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │              scheduling-service (Cloud Run)                    │  │
│  │                                                                │  │
│  │  Controllers:                                                  │  │
│  │    axle-to-fhir-store  │  fhir-store-to-axle                   │  │
│  │    commons-to-create-axle  │  config-from-axle                 │  │
│  │                                                                │  │
│  │  DB Models:                                                    │  │
│  │    appointment_axle_sync  │  axle_sync_transaction             │  │
│  └──────────┬─────────────────────────────────────────────────────┘  │
│             ▼                                                        │
│  ┌──────────────────────┐    ┌─────────────────────┐                │
│  │ Google Healthcare     │    │ dbt / BigQuery       │                │
│  │ FHIR Store            │    │ (Analytics)          │                │
│  │ (Source of truth)     │    │                      │                │
│  └──────────────────────┘    └─────────────────────┘                │
└──────────────────────────────────────────────────────────────────────┘
```

## File Map

### SDK Package (`packages/axle/`)

The `@cityblock/axle` npm package (v5.2.1). Published via GitHub Actions.

```
packages/axle/
├── package.json                    # @cityblock/axle
├── src/
│   ├── index.ts                    # Barrel export (client + config + types)
│   ├── config.ts                   # Environment config (URLs, project names)
│   ├── axle-client.ts              # Main API client class (all HTTP methods)
│   ├── helpers/
│   │   └── axle-workforce-management-client-helpers.ts  # DateRange validation
│   └── types/
│       ├── index.ts
│       └── types-v2/
│           ├── index.ts            # Barrel export for all v2 types
│           ├── common.ts           # Address, Contact, Duration, DateRange, Pagination, Coverage
│           ├── enums.ts            # SummaryStatus, ClinicianAppointmentStatus, PatientConfirmationStatus
│           ├── visit.ts            # PotentialVisit, VisitFull, TimeslotPreferences
│           ├── visit-inputs.ts     # CreateVisitInput, EditVisitInput, time/clinician option inputs
│           ├── visit-outputs.ts    # CreateVisitOutput, VisitTimeOptionsOutput, ClinicianOptionsOutput
│           ├── patient.ts          # PatientFull, PatientAppointment, CommunicationSettings
│           ├── patient-inputs.ts   # PatientInput, PatientEditInput
│           ├── patient-outputs.ts  # PatientCreateOutput
│           ├── clinician.ts        # Clinician, ClinicianInput, ClinicianUpdateInput
│           ├── clinician-appointment.ts  # ClinicianAppointment variants, Encounter, Filter
│           ├── clinician-outputs.ts      # CliniciansOutput, ShiftsOutput, ShiftBlocksOutput
│           ├── service.ts          # Service, ServiceBundle, ServiceBundleWithServices, ServiceArea
│           ├── service-outputs.ts  # ServicesOutput, ServiceBundlesOutput
│           ├── territory.ts        # Territory, TerritorySummary, TerritoryInput
│           ├── shifts.ts           # Shift, ShiftBlock, inputs/updates
│           ├── qualifications.ts   # Qualification, QualificationInput
│           ├── care-team.ts        # CareTeam, CareTeamInput
│           ├── payer.ts            # Payer, PayersOutput
│           ├── document.ts         # DocumentDownloadLinkOutput
│           ├── visit-reservation.ts # VisitReservationInput/Output
│           ├── visit-request.ts    # VisitRequest, VisitRequestInput
│           ├── coverage-inputs.ts  # CoverageLookupInput, PotentialVisitFromServiceBundleInput
│           ├── coverage-outputs.ts # CoverageLookupOutput
│           └── webhook.ts          # VisitWebhook, TriggeringLocation
└── __tests__/
    └── axle-client.spec.ts
```

### Scheduling Service - Axle Client Singleton

```
scheduling-service/server/apis/axle/
└── index.ts                        # getAxleClient() singleton factory
```

Usage: `const axleClient = await getAxleClient(); const axle = axleClient.asUser(userId);`

### Scheduling Service - Controllers

```
scheduling-service/server/controllers/
├── axle-to-fhir-store.controller.ts     # Sync Axle visits → FHIR Store
├── fhir-store-to-axle.controller.ts     # Sync FHIR appointments → Axle
├── commons-to-create-axle.controller.ts # Create visits in Axle from Commons
└── config-from-axle.controller.ts       # Cache config data from Axle
```

### Scheduling Service - Routes

```
scheduling-service/server/routes/
├── axle.routes.ts       # POST / (Axle sync endpoint)
├── sync.routes.ts       # Mounts axle router
├── create.routes.ts     # Mounts Axle create endpoint
├── config.routes.ts     # Mounts config-from-axle endpoint
└── fhir-store.routes.ts # Mounts Axle-to-FHIR sync endpoint
```

### Scheduling Service - Sync Services

**FHIR Store → Axle** (outbound sync):
```
scheduling-service/server/services/axle/sync/
├── reconcile-appointment.ts    # Core reconciliation logic
├── transform-appointment.ts    # FHIR appointment → Axle format
├── transform-location.ts       # Location transforms
├── transform-practitioner.ts   # Practitioner transforms
├── transform-patient.ts        # Patient transforms
├── helpers.ts                   # Helper functions
└── __tests__/
    ├── transform-appointment.spec.ts
    └── transform-location.spec.ts
```

**Axle creation from internal data**:
```
scheduling-service/server/services/axle/create/
├── transform-appointment.ts     # Create FHIR bundle for new Axle visit
├── transform-practitioners.ts   # Practitioner transforms for creation
├── transform-patient.ts         # Patient transforms for creation
├── transform-slot-schedule.ts   # Slot/schedule transforms
├── helpers.ts                   # Creation helpers
└── create-resources-for-dev.ts  # Dev-only resource creation
```

**Axle → FHIR Store** (inbound sync):
```
scheduling-service/server/services/fhir-store/axle/
├── reconcile-appointments.ts              # Core reconciliation logic
├── reconcile-helpers.ts                   # Reconciliation helpers
├── transform-bundle.ts                    # Axle → FHIR bundle transforms
├── transform-helpers.ts                   # Transform helpers
├── transform-patient-participant.ts       # Patient participant transforms
├── transform-practitioner-participants.ts # Practitioner participant transforms
├── transform-slot-schedule.ts             # Slot/schedule transforms
└── __tests__/
    ├── reconcile-appointment.spec.ts
    ├── reconcile-helpers.spec.ts
    ├── transform-bundle.spec.ts
    └── transform-patient-participant.spec.ts
```

### Scheduling Service - Database Models

```
scheduling-service/server/models/
├── axle-sync-transaction.ts              # Distributed lock for sync operations
├── appointment-axle-sync.ts              # Sync state tracking per appointment
└── migrations/
    └── 20240401205218_appointment-axle-sync.ts
```

### Scheduling Service - Config Caching

```
scheduling-service/server/services/config/
├── axle-config.service.ts     # Fetch and cache appointment types/locations from Axle
├── axle-config-types.ts       # Types for config caching
└── axle-config-helpers.ts     # GCS storage, fuzzy matching helpers

scheduling-service/server/config/
├── defaults.ts                # AXLE_ENV: 'dev' default
└── get-config-for-deployment.ts  # Per-environment AXLE_ENV config
```

### Cloud Functions

```
cloud_functions/
├── axle-visit-webhook-v2stable/        # Receives Axle webhooks, validates signature, publishes to PubSub
│   └── src/index.ts
├── transform-axle-to-fhir-v2stable/    # Transforms webhook data to FHIR bundles
│   ├── src/index.ts
│   └── src/config.ts
├── create-sync-to-fhir-store-from-axle-task/  # Creates Cloud Task for Axle→FHIR sync
│   ├── src/index.ts
│   ├── src/config.ts
│   └── src/utils.ts
└── create-sync-to-axle-from-fhir-store-task/  # Creates Cloud Task for FHIR→Axle sync
    ├── src/index.ts
    ├── src/config.ts
    └── src/utils.ts
```

### Terraform Infrastructure

```
terraform/
├── secrets_scheduling.tf            # axle-api-key, axle-api-webhook-signature-key
├── pubsub_topics_scheduling.tf      # axleVisitWebhookNotificationsV2Stable, transformedAxleAppointments
├── cloud_tasks_scheduling.tf        # syncToAxleTaskQueue, syncToFhirStoreFromAxleTaskQueue
├── dataflow_scheduling.tf           # axle-visit-webhook-v2stable-to-gcs (archival)
├── iam.tf                           # IAM bindings for transformed_axle_appointments topic
├── datadog_scheduling.tf            # Axle error monitors
└── datadog_scheduling_json.tf       # Axle error monitors (JSON-based)
```

### dbt Models (Analytics)

```
dbt/models/staging/
├── axle_clinicians/
│   ├── _axle_clinicians__sources.yml
│   ├── _axle_clinicians__models.yml
│   ├── stg_axle_clinicians__clinician_data.sql
│   └── stg_axle_clinicians__clinician_qualifications.sql
├── axle_territories/
│   ├── _axle_territories__sources.yml
│   ├── _axle_territories__models.yml
│   └── stg_axle_territories__territory_zip_codes.sql
└── axle_availability/
    ├── _axle_availability__sources.yml
    ├── _axle_availability__models.yml
    ├── stg_axle_availability__shift_historical.sql
    └── stg_axle_availability__shift_block_historical.sql

dbt/models/exports/commons/
├── xpt_commons__axle_clinician.sql
└── xpt_commons__axle_clinician_qualification.sql
```

### GitHub Actions

```
.github/workflows/
├── workflow-npmpublish-package-axle.yml      # Publish @cityblock/axle
└── workflow-prepatch-npm-package-axle.yml    # Pre-patch version bump
```

## GCP Resources

| Resource | Name | Purpose |
|----------|------|---------|
| **Secret** | `axle-api-key` | Bearer token for API auth |
| **Secret** | `axle-api-webhook-signature-key` | HMAC key for webhook validation |
| **PubSub** | `axleVisitWebhookNotificationsV2Stable` | Raw webhook events |
| **PubSub** | `transformedAxleAppointments` | FHIR-transformed appointment data |
| **Cloud Task Queue** | `syncToAxleTaskQueue` | FHIR→Axle sync tasks |
| **Cloud Task Queue** | `syncToFhirStoreFromAxleTaskQueue` | Axle→FHIR sync tasks |
| **GCS Bucket** | `cbh-axle-data-{env}` | Cached config (`service-areas.json`) |
| **Dataflow** | `axle-visit-webhook-v2stable-to-gcs` | Archive webhook data |

## Key Patterns

### Adding a New Axle API Method

1. Add types in `packages/axle/src/types/types-v2/` (create new file or extend existing)
2. Export from `packages/axle/src/types/types-v2/index.ts`
3. Add method to `packages/axle/src/axle-client.ts` following existing patterns
4. Add tests in `packages/axle/__tests__/axle-client.spec.ts`
5. Bump version in `packages/axle/package.json`

### Adding a New Sync Direction

1. Create transform services in `scheduling-service/server/services/`
2. Create controller in `scheduling-service/server/controllers/`
3. Add route in `scheduling-service/server/routes/`
4. If async, add Cloud Function + PubSub topic + Cloud Task queue (in `terraform/`)
