# Axle Health API - Type Reference

All types are defined in `packages/axle/src/types/types-v2/` and exported from `@cityblock/axle`.

## Common Types (`common.ts`)

```typescript
type Contact = {
  first_name: string;
  last_name: string;
  phone: string | null;    // E.164 format (e.g. +14155552671)
  email: string | null;
};

type Address = {
  line1: string;
  line2: string;
  city: string;
  state: string;
  zip_code: string;
};

type Metadata = { [key: string]: string };

type Duration = number;  // Positive multiple of 15 (minutes)

type DateRange = {
  start_datetime: string;  // ISO-8601
  end_datetime: string;    // ISO-8601
};

type Recurrence = {
  rrule: string;       // iCal RRULE format
  exdate: string[];    // Excluded dates
};

type Pagination = {
  offset: number;
  count_limit: number;
  total_records: number;
};

type Coverage = {
  mobile_territories: { territory_id: string }[];
  virtual_territories: { territory_id: string }[];
};
```

## Enums (`enums.ts`)

```typescript
type SummaryStatus =
  | 'UNSCHEDULED' | 'SCHEDULED' | 'CONFIRMED'
  | 'EN_ROUTE' | 'AT_LOCATION' | 'IN_REVIEW'
  | 'COMPLETED' | 'OTHER_OUTCOME' | 'CANCELED';

type ClinicianAppointmentStatus = 'NOT_STARTED' | 'EN_ROUTE' | 'AT_LOCATION' | 'ENDED';

type PatientConfirmationStatus = 'NONE' | 'ACCEPTED' | 'DECLINED';

type ServiceId = string;
```

## Patient Types (`patient.ts`, `patient-inputs.ts`, `patient-outputs.ts`)

```typescript
type PatientFull = {
  patient_id: string;
  first_name: string;
  last_name: string;
  dob: string;
  sex: string;
  email: string | null;
  phone: string | null;
  addresses: Address[];
  preferred_language: string;
  metadata: Metadata;
  external_id: string | null;
  communication_settings: CommunicationSettings;
  payers: PatientPayer[];
};

type CommunicationSettings = {
  allows_automated_calls: boolean;
  allows_clinician_calls: boolean;
  allows_automated_sms: boolean;
  allows_clinician_sms: boolean;
  allows_automated_emails: boolean;
};

type PatientPayer = { payer_id: string; code: string; description: string };
type PatientAppointment = {
  patient_id: string;
  patient_confirmation_status: PatientConfirmationStatus;
  contact: Contact | null;
};

// Inputs
type PatientInput = Omit<PatientFull, 'patient_id'>;
type PatientEditInput = Partial<PatientFull>;

// Outputs
type PatientCreateOutput = { patient_id: string };
```

## Clinician Types (`clinician.ts`, `clinician-outputs.ts`)

```typescript
type Clinician = {
  clinician_id: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  address: Address | null;
  language_codes: string[];
  qualifications: { qualification_id: string }[];
  default_shift_options: Coverage;
};

type ClinicianInput = Omit<Clinician, 'clinician_id' | 'created_at' | 'languages_spoken' | 'qualifications' | 'address'> & {
  address?: Address;
  language_codes?: string[];
  qualifications?: { qualification_id: string }[];
};

type ClinicianUpdateInput = {
  first_name?: string | null;
  last_name?: string | null;
  email?: string | null;
  phone?: string | null;
  address?: Address;
  language_codes?: string[] | null;
  qualifications?: { qualification_id: string }[] | null;
  default_shift_options?: Coverage | null;
};

type CliniciansOutput = { items: Clinician[]; pagination: Pagination };
```

## Clinician Appointment Types (`clinician-appointment.ts`)

```typescript
type Encounter = {
  clinician_appointment_id: string;
  patient_id: string;
  services: { service_id: ServiceId }[];
};

type ClinicianAppointmentBase = {
  clinician_appointment_id: string;
  is_virtual: boolean;
  start_offset_minutes: Duration | null;
  duration_override_minutes: Duration | null;
};

type ClinicianAppointmentPotentialVisit = ClinicianAppointmentBase & {
  created_from_service_bundle_clinician_appointment_template_id: string | null;
};

type ClinicianAppointmentToCreate = ClinicianAppointmentBase & {
  clinician_id: string | null;
};

type ClinicianAppointmentToEdit = Omit<ClinicianAppointmentBase, 'is_virtual'> & {
  clinician_id: string | null;
  clinician_appointment_status: ClinicianAppointmentStatus;
};

type ClinicianAppointmentFull = ClinicianAppointmentBase & {
  clinician_id: string | null;
  duration_minutes: Duration;
  duration_computed_minutes: Duration;
  clinician_appointment_status: ClinicianAppointmentStatus;
};

type ClinicianAppointmentFilter = {
  clinician_appointment_id: string;
  clinicians: { clinician_id: string }[];
};
```

## Visit Types (`visit.ts`, `visit-inputs.ts`, `visit-outputs.ts`)

```typescript
type PotentialVisit = {
  service_area_id: string;
  duration_minutes: Duration;
  address: Address;
  clinician_appointments: ClinicianAppointmentPotentialVisit[];
  encounters: Encounter[];
  created_from_service_bundle_id: string | null;
  clinic_id: string | null;
};

type TimeslotPreferences = {
  preferred_windows: DateRange[];
};

type VisitFull = {
  visit_id: string;
  summary_status: SummaryStatus;
  priority: 'HIGH' | 'STANDARD' | 'URGENT';
  service_area_id: string;
  address: Address;
  clinic_id: string | null;
  timezone: string;
  start_datetime: string | null;
  duration_minutes: Duration;
  duration_override_minutes: Duration | null;
  duration_computed_minutes: Duration;
  timeslot_preferences: TimeslotPreferences | null;
  patient_appointments: PatientAppointment[];
  clinician_appointments: ClinicianAppointmentFull[];
  created_from_service_bundle_id: string | null;
  created_from_reservation: string | null;
  encounters: Encounter[];
  external_id: string | null;
  metadata: Metadata;
  notes_for_clinicians: string;
  notes_for_dashboard: string;
  documents: string[];
};

// Create inputs - discriminated union on start_datetime
type CreateScheduledVisitInput = CreateVisitBaseInput & {
  start_datetime: string;
  timeslot_preferences?: TimeslotPreferences | null;
};
type CreateUnscheduledVisitInput = CreateVisitBaseInput & {
  start_datetime: null;
  timeslot_preferences: TimeslotPreferences;  // required for unscheduled
};
type CreateVisitInput = CreateScheduledVisitInput | CreateUnscheduledVisitInput;

type EditVisitInput = Partial<Pick<VisitFull, 'summary_status' | 'address' | 'clinic_id' | 'start_datetime' | ...>> & Partial<{
  clinician_appointments_to_edit: ClinicianAppointmentToEdit[];
  clinician_appointments_to_delete: { clinician_appointment_id: string }[];
  encounters_to_add: Encounter[];
  encounters_to_edit: Encounter[];
  encounters_to_delete: Encounter[];
}>;

// Outputs
type CreateVisitOutput = { visit_id: string; message?: string; errors?: { loc: string[]; err: string }[] };
type GetVisitOutput = VisitFull;
type EditVisitOutput = { message?: string };
type VisitTimeOptionsOutput = { recommended_time_options: DateRange[] };
type ClinicianOptionsOutputAtTime = {
  clinician_options: { clinician_appointment_id: string; recommended_clinicians: { clinician_id: string }[] }[];
};
type ClinicianOptionsOutputOverDateRange = {
  clinician_options: { clinician_appointment_id: string; eligible_clinicians: { clinician_id: string }[] }[];
};
type PotentialVisitFromServiceBundleOutput = { potential_visit: PotentialVisit };
```

## Service Types (`service.ts`, `service-outputs.ts`)

```typescript
type Service = {
  service_id: ServiceId;
  name: string;
  description: string;
  duration_minutes: Duration;
  is_virtual: boolean;
};

type ServiceBundle = { service_bundle_id: string; name: string; description: string };

type ServiceBundleWithServices = ServiceBundle & {
  positions: { name: string; service_ids: string[] }[];
};

type ServiceArea = {
  service_area_id: string;
  name: string;
  type: string;
  address: Address | null;
  services: Service[];
  service_bundles: ServiceBundle[];
};

type ServicesOutput = { items: Service[]; pagination: Pagination };
type ServiceBundlesOutput = { items: ServiceBundleWithServices[]; pagination: Pagination };
```

## Territory Types (`territory.ts`)

```typescript
type TerritorySummary = {
  territory_id: string;
  name: string;
  metadata: { [key: string]: string };
};

type Territory = {
  territory_id: string;
  name: string;
  zip_codes: string[];  // Only in full response (GET by ID)
  metadata: { [key: string]: string };
};

type TerritoriesOutput = { items: TerritorySummary[]; pagination: Pagination };
type TerritoryInput = Omit<Territory, 'territory_id' | 'metadata'>;
type TerritoryUpdate = { name?: string; zip_codes?: string[]; metadata?: { [key: string]: string } };
```

## Shift Types (`shifts.ts`)

```typescript
type Shift = {
  shift_id: string;
  start_datetime: string;
  end_datetime: string;
  time_zone: string;
  clinician_id: string;
  notes?: string;
  rrule: string;
  exclude_datetimes: string[];
  clinic_ids: string[] | null;
  mobile_territories: { territory_id: string }[];
  virtual_territories: { territory_id: string }[];
};

type ShiftInput = Omit<Shift, 'shift_id'>;
type ShiftUpdateInput = Partial<Shift>;  // all fields optional

type ShiftBlock = {
  shift_block_id: string;
  clinicians: { clinician_id: string }[];
  timezone: string;
  start_datetime: string;
  end_datetime: string;
  recurrence: Recurrence | null;
  start_address: Address | null;
  notes: string;
};

type ShiftBlockInput = Omit<ShiftBlock, 'shift_block_id'>;
type ShiftBlockUpdateInput = { start_datetime?: string; end_datetime?: string };

type ShiftsOutput = { items: Shift[]; pagination: Pagination };
type ShiftBlocksOutput = { items: ShiftBlock[]; pagination: Pagination };
```

## Qualification Types (`qualifications.ts`)

```typescript
type Qualification = { qualification_id: string; code: string; description?: string };
type QualificationInput = Omit<Qualification, 'qualification_id'>;
type QualificationsOutput = { items: Qualification[]; pagination: Pagination };
```

## Care Team Types (`care-team.ts`)

```typescript
type CareTeam = {
  care_team_uuid: string;
  patients: { patient_id: string }[];
  clinicians: { clinician_id: string }[];
};

type CareTeamInput = Omit<CareTeam, 'care_team_uuid'>;
type CareTeamUpdateInput = Partial<CareTeam>;
type CareTeamsOutput = { items: CareTeam[]; pagination: Pagination };
```

## Payer Types (`payer.ts`)

```typescript
type Payer = { payer_id: string; code: string; description: string };
type PayersOutput = { items: Payer[]; pagination: Pagination };
```

## Document Types (`document.ts`)

```typescript
type DocumentDownloadLinkOutput = { link: string };
```

## Visit Reservation Types (`visit-reservation.ts`)

```typescript
type VisitReservationInput = { potential_visit: PotentialVisit; expiry_datetime: string };
type VisitReservationOutput = { visit_reservation_id: string };
type DeleteReservationOutput = Record<string, never>;
```

## Visit Request Types (`visit-request.ts`)

```typescript
type VisitRequest = {
  visit_request_id: string;
  patient_id: string;
  fulfillment_window: { start_date: string; end_date: string };
  clinician_appointments: { clinician_appointment_id: string; clinician_id: string }[] | null;
  encounters: { clinician_appointment_id: string; services: { service_id: string }[] }[] | null;
  state: 'PENDING' | 'APPROVED' | 'REJECTED';
  address: Address;
  clinic_id: string | null;
  priority: 'STANDARD' | 'HIGH' | 'URGENT';
  external_id: string | null;
  metadata: Metadata;
};

type VisitRequestInput = Omit<VisitRequest, 'visit_request_id'>;
type VisitRequestUpdateInput = Partial<VisitRequestInput>;
```

## Coverage Lookup Types (`coverage-inputs.ts`, `coverage-outputs.ts`)

```typescript
// Input is one of three shapes:
type CoverageLookupInput =
  | { address: Address }
  | { zipcode: string }
  | { clinic_id: string };

// For generating potential visits from service bundles:
type PotentialVisitFromServiceBundleInput =
  | { address: Address; patient_id: string; service_area_id: string; service_bundle_id: string }
  | { clinic_id: string; patient_id: string; service_area_id: string; service_bundle_id: string };

type CoverageLookupOutput = { service_areas: ServiceArea[] };
```

## Webhook Types (`webhook.ts`)

```typescript
type TriggeringLocation = 'PATIENT_PORTAL' | 'CLINICIAN_APP' | 'DASHBOARD' | 'API' | 'AXLE_SYSTEM';

type VisitWebhook = {
  triggering_location: TriggeringLocation;
  type: 'visit';
  updated_at: string;
  visit: VisitFull;
};
```
