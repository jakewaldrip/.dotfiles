---
name: dataloader-dual-mode-migration
description: Migrate dataloaders to dual-mode pattern supporting both patientId and enrollmentId for Member Model 2.0. Use when converting a patient-based dataloader to support the MemberModelV2Switch.
---

# Dual-Mode Dataloader Migration

Migrate patient-based dataloaders to support dual-mode operation (patientId and enrollmentId) for Member Model 2.0.

## When to Use

- Converting a loader that currently keys by `patientId` to support dual-mode (patientId/enrollmentId)
- The loader returns data scoped to a patient that should be filtered by enrollment when MemberModelV2Switch is ON

## Prerequisites

1. **Model already uses PatientEnrollmentRelatedClassMixin** - Required for `withDualModePatientKeys()` query builder. **Do NOT add this mixin yourself.** Which models need the mixin is a human design decision. If the model doesn't already extend this mixin, stop and inform the user that the model is not set up for dual-mode migration.
2. **Table has `patientEnrollmentId` column** - Data must be linkable to enrollments
3. **Loader currently uses `patientId`** as the key (string or included in compound key)

## Stop Conditions

**Do NOT proceed with the migration if any of the following are true:**

- The model does not already extend `PatientEnrollmentRelatedClassMixin`. Inform the user and stop.
- The table does not have a `patientEnrollmentId` column. Inform the user and stop.

Adding the enrollment mixin to a model is a separate architectural decision that must be made by the team, not as part of a dataloader migration.

## Key Files

| File                                                             | Purpose                                |
| ---------------------------------------------------------------- | -------------------------------------- |
| `commons-packages/backend/graphql/shared/loaders.ts`             | DataLoaders class - loader definitions |
| `commons-packages/backend/graphql/shared/dual-mode-patient-key.ts` | DualModePatientKey type and normalizer |
| Model file (e.g., `models/goal/goal.ts`)                         | Batch load method                      |
| Caller files (resolvers, services)                               | Usage sites to update                  |

## Migration Pattern Overview

```
BEFORE MIGRATION
================
Loader:  returnsMultipleItems(Model.getByPatient.bind(Model), ...)
Caller:  dataLoaders.xxxForPatient.load(patientId)
Model:   static async getByPatient(patientIds: readonly string[])

                              |
                              v

AFTER MIGRATION
===============
Loader:  returnsMultipleItems<DualModePatientKey, Model, ...>(
           Model.loadByPatient.bind(Model),
           (item) => { /* dual-mode key */ },
           normalizeDualModeKey,
         )
Caller:  dataLoaders.xxxForPatient.load({ patientId })
Model:   static async loadByPatient(keys: readonly DualModePatientKey[])
```

## Templates

### Model Method Template

Create a new `loadByXxx` method in the model:

```typescript
import type { DualModePatientKey } from '@commons/backend/graphql/shared/dual-mode-patient-key.js';

/**
 * Data loader method for retrieving [items] by patient keys.
 * Uses dual-mode filtering based on MemberModelV2Switch.
 *
 * @param keys - Array of DualModePatientKey objects
 */
static async loadByPatient(keys: readonly DualModePatientKey[]) {
  return ModelName.query()
    .withDualModePatientKeys([...keys])
    .andWhere({ deletedAt: null })
    // Add other filters and ordering as needed
    .orderBy('createdAt', 'DESC');
}
```

### Loader Definition Template

Update the loader in `loaders.ts`:

```typescript
import type { DualModePatientKey } from '@commons/backend/graphql/shared/dual-mode-patient-key.js';
import { normalizeDualModeKey } from '@commons/backend/graphql/shared/dual-mode-patient-key.js';
import { MemberModelV2Switch } from '@commons/backend/lib/member-model-v2-switch.js';

/**
 * Dual-mode loader for [description].
 * Accepts DualModePatientKey with optional enrollmentId.
 * When MemberModelV2Switch is ON and enrollmentId is provided, keys by enrollmentId.
 * Otherwise, keys by patientId (legacy behavior).
 */
xxxForPatient = returnsMultipleItems<DualModePatientKey, ModelName, DualModePatientKey>(
  ModelName.loadByPatient.bind(ModelName),
  (item): DualModePatientKey => {
    // Return the appropriate key based on switch state
    if (MemberModelV2Switch.shouldApplyEnrollmentLogic() && item.patientEnrollmentId) {
      return { patientId: item.patientId, enrollmentId: item.patientEnrollmentId };
    }
    return { patientId: item.patientId };
  },
  // Normalize key for cache lookup
  normalizeDualModeKey,
);
```

### Caller Update Pattern

```typescript
// BEFORE
context.dataLoaders.xxxForPatient.load(patientId);

// AFTER (basic - just patientId)
context.dataLoaders.xxxForPatient.load({ patientId });

// AFTER (with enrollmentId when available)
context.dataLoaders.xxxForPatient.load({
  patientId: patient.id,
  enrollmentId: patient.activeEnrollmentId,
});
```

### Test Template

Create/update tests in the model's `__tests__/` directory:

```typescript
import { describeDualMode } from '@commons/backend/__tests__/helpers/member-model-v2-switch-test-helper.js';

describeDualMode('loadByPatient', () => {
  it('should load items for a single patient', async () => {
    const { patient, expectedItems } = await setup();
    const items = await ModelName.loadByPatient([{ patientId: patient.id }]);

    expect(items.length).toBeGreaterThanOrEqual(expectedItems.length);
    const itemIds = items.map((item) => item.id);
    expectedItems.forEach((expected) => {
      expect(itemIds).toContain(expected.id);
    });
  });

  it('should load items for multiple patients', async () => {
    const { patient1, patient2 } = await setup();
    const items = await ModelName.loadByPatient([
      { patientId: patient1.id },
      { patientId: patient2.id },
    ]);

    // Assert items from both patients are returned
  });

  it('should not return deleted items', async () => {
    const { patient, deletedItem, activeItem } = await setup();
    const items = await ModelName.loadByPatient([{ patientId: patient.id }]);

    const itemIds = items.map((item) => item.id);
    expect(itemIds).not.toContain(deletedItem.id);
    expect(itemIds).toContain(activeItem.id);
  });

  it('should return empty array for empty keys array', async () => {
    const items = await ModelName.loadByPatient([]);
    expect(items).toHaveLength(0);
  });

  it('should return empty array for patient with no items', async () => {
    const { patientWithNoItems } = await setup();
    const items = await ModelName.loadByPatient([{ patientId: patientWithNoItems.id }]);
    expect(items).toHaveLength(0);
  });
});
```

## Verification Checklist

After migration:

- [ ] Model has new `loadByPatient` method using `withDualModePatientKeys`
- [ ] Loader definition uses `DualModePatientKey` type parameters
- [ ] Loader uses `normalizeDualModeKey` as third argument
- [ ] Loader id function returns `DualModePatientKey` with switch check
- [ ] All callers updated to pass `{ patientId }` object
- [ ] Tests added with `describeDualMode` wrapper
- [ ] Typecheck passes: `npm run typecheck`
- [ ] Tests pass: `npm test <test-file>`

## References

- [Dataloaders documentation](docs/dataloaders.md)
- Example: `goalsForPatient` in `commons-packages/backend/graphql/shared/loaders.ts`
- [Goal.loadByPatient](commons-packages/backend/models/goal/goal.ts) - Example model method
- [Goal tests](commons-packages/backend/models/goal/__tests__/goal.spec.ts) - Example tests with `describeDualMode`
- [DualModePatientKey](commons-packages/backend/graphql/shared/dual-mode-patient-key.ts)
- [PatientEnrollmentRelatedClassMixin](commons-packages/backend/models/patient-enrollment/patient-enrollment-related.ts)

See [WORKFLOW.md](./WORKFLOW.md) for step-by-step migration instructions.
