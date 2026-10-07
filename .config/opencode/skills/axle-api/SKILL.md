---
name: axle-api
description: Use when working with the Axle Health API integration in cbh-scheduling — a third-party healthcare workforce platform for scheduling visits and managing clinicians, territories, shifts, and patients. Covers Axle endpoints, types, workflows, and codebase navigation.
---

# Axle Health API Skill

Use this skill when working with the Axle Health API integration in `cbh-scheduling`. Axle Health is a third-party healthcare workforce management platform for scheduling visits, managing clinicians, territories, shifts, and patients.

## Supplemental Files

Load these as needed to minimize context:

| File | When to Load |
|------|-------------|
| `ENDPOINTS.md` | Writing or modifying API calls, adding new endpoints to the client |
| `TYPES.md` | Working with Axle data structures, adding/changing type definitions |
| `WORKFLOWS.md` | Implementing visit creation, scheduling flows, webhook handling, or bidirectional sync |
| `CODEBASE.md` | Navigating repo structure, finding where Axle integrations live, understanding the architecture |

## Quick Reference

### API Environments

| Environment | Base URL | GCP Project |
|-------------|----------|-------------|
| `dev` | `https://api.axlehealth-dev.com/api/v2-stable/` | `cbh-scheduling-dev` |
| `staging` | `https://api.axlehealth-dev.com/api/v2-stable/` | `cbh-scheduling-staging` |
| `production` | `https://api.axlehealth.com/api/v2-stable/` | `cbh-scheduling-production` |

- Controlled by `AXLE_ENV` environment variable (`'dev' | 'staging' | 'production'`)
- Config defined in `packages/axle/src/config.ts`

### Authentication

- **Bearer token** via `Authorization: Bearer <token>` header
- Token stored in GCP Secret Manager: `projects/<project>/secrets/axle-api-key/versions/latest`
- Webhook signatures use HMAC-SHA256 with a separate secret: `axle-api-webhook-signature-key`

### SDK Package

The `@cityblock/axle` npm package (located at `packages/axle/`) wraps the Axle REST API:

```typescript
import { AxleClient, initializeAxleClient } from '@cityblock/axle';

// Initialize (authenticates via GCP Secret Manager)
const client = await initializeAxleClient({
  axleClientEnvironment: 'dev',  // or 'staging' | 'production'
  logger,
  secretsClient,  // optional, defaults to new SecretManagerServiceClient()
});

// Use with a user context
const axle = client.asUser(userId);

// Make API calls
const visit = await axle.getVisitById('visit-uuid');
const patient = await axle.createPatient({ ... });
```

- The client uses **axios** with 2 automatic retries
- 400 errors are logged before rejection
- All list endpoints support **offset-based pagination** with `offset` and `count_limit` params
- `getAll*` convenience methods handle pagination automatically (default page size: 100)

### Singleton Pattern

In the scheduling service, use the singleton factory:

```typescript
import { getAxleClient } from '../apis/axle';

const axleClient = await getAxleClient();
const axle = axleClient.asUser(userId);
```

Defined in `scheduling-service/server/apis/axle/index.ts`.

### API Conventions

- **API Version**: `v2-stable` (all endpoints)
- **Pagination**: Offset-based. Responses include `{ items: T[], pagination: { offset, count_limit, total_records } }`
- **Must-ignore policy**: New keys may be added to responses at any time; never fail on unknown fields
- **Error responses**: Non-200 responses return `{ message: string, errors?: { loc: string[], err: string }[] }`
- **HTTP response codes**: `200` success, `400` bad request, `401` unauthorized, `403` forbidden, `404` not found, `422` validation error, `500` server error
- **Duration fields**: Always positive multiples of 15 (minutes)
- **Dates/times**: ISO-8601 format strings
- **Phone numbers**: E.164 format (e.g., `+14155552671`)

### Glossary (Key Concepts)

| Term | Meaning |
|------|---------|
| **Visit** | Fundamental scheduling unit: one or more patients seen at a time/location by one or more clinicians |
| **Potential Visit** | A visit template (not yet created) with service area, address, duration, clinician appointments, encounters |
| **Clinician Appointment** | A slot on a visit to be filled by a clinician; has duration, virtual flag, status |
| **Patient Appointment** | A patient's connection to a visit, including confirmation status and contact info |
| **Encounter** | Links a clinician appointment to a patient with specific services |
| **Service** | A procedure a clinician can perform (has name, duration, virtual flag) |
| **Service Bundle** | A reusable configuration of services and clinician appointment positions |
| **Service Area** | Rules for creating visits in a given clinic or set of territories (operating hours, etc.) |
| **Territory** | Named collection of zip codes representing a geographic region |
| **Shift** | A block of time when a clinician is available to work, with territory/clinic assignments |
| **Shift Block** | A block of time when clinicians are unavailable, even with an active shift |
| **Care Team** | A set of clinicians primarily responsible for a patient's care |
| **Qualification** | Tags for legal/operational requirements clinicians must meet to perform a service |
| **Clinic** | A physical location where patients are served centrally (vs. mobile visits) |
| **Delivery Model** | Mobile (at patient's location) or In-clinic (at a clinic) |
| **Coverage** | Territories a clinician can work in (mobile and virtual) |
| **Payer** | Insurance/payer entity associated with patients |

### Visit Statuses (SummaryStatus)

```
UNSCHEDULED -> SCHEDULED -> CONFIRMED -> EN_ROUTE -> AT_LOCATION -> IN_REVIEW -> COMPLETED
                                                                                   |
                                                                             OTHER_OUTCOME
     |____________________________________________________________________________|
     |-> CANCELED (can happen from most states)
```

### Webhook Events

Axle sends webhooks for `visit` and `shift` events. Currently only `visit` webhooks are processed.

**Signature verification** uses HMAC-SHA256:
1. Parse `Axle-Signature` header: `t=<timestamp>,v1=<signature>`
2. Construct message: `<timestamp>.<rawBody>`
3. Generate HMAC-SHA256 with the webhook secret key
4. Compare using timing-safe equality

See `cloud_functions/axle-visit-webhook-v2stable/src/index.ts` for the implementation.

### External Documentation

- Docs (access-restricted): `https://developers.axlehealth.com/`
- OpenAPI spec: `https://developers.axlehealth.com/open-api.yaml`
- Status page: `https://status.axlehealth.com/`
- Support: `techsupport@axlehealth.com`
