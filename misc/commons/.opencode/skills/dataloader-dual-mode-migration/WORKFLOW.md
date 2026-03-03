# Dual-Mode Dataloader Migration Workflow

Step-by-step guide for migrating a patient-based dataloader to dual-mode pattern.

## Phase 1: Analysis

### 1.1 Identify Target Loader

Find the loader in `commons-packages/backend/graphql/shared/loaders.ts`:

```typescript
// Example: Look for loaders that use patientId
xxxForPatient = returnsMultipleItems(
  Model.getByPatient.bind(Model),
  (item) => item.patientId,
);
```

### 1.2 Find Model Method

Identify the batch method the loader calls (e.g., `Model.getByPatient`).

### 1.3 Find All Callers

Search for all usages of the loader:

```bash
# Find all callers
rg "xxxForPatient\.load" -t ts
```

### 1.4 Verify Prerequisites

Confirm:

- [ ] Model extends `PatientEnrollmentRelatedClassMixin` (or can be updated to)
- [ ] Table has `patientEnrollmentId` column
- [ ] Items have `patientId` and `patientEnrollmentId` properties

If model doesn't use the mixin, add it:

```typescript
// BEFORE
export default class ModelName extends BaseModel { ... }

// AFTER
import { Mixin } from 'ts-mixer';
import { PatientEnrollmentRelatedClassMixin } from '@commons/backend/models/patient-enrollment/patient-enrollment-related.js';

export default class ModelName extends Mixin(BaseModel, PatientEnrollmentRelatedClassMixin) { ... }
```

---

## Phase 2: Model Changes

### 2.1 Create New loadBy Method

Add a new method to the model (always create new, don't modify existing):

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
    // Copy filters and ordering from original method
    .orderBy('createdAt', 'DESC');
}
```

Key differences from original method:

- Accepts `readonly DualModePatientKey[]` instead of `string | readonly string[]`
- Uses `withDualModePatientKeys()` instead of `whereIn('patientId', ...)`
- No input normalization needed (data loaders always pass arrays)

---

## Phase 3: Loader Changes

### 3.1 Add Imports

At top of `loaders.ts`, add if not already present:

```typescript
import type { DualModePatientKey } from '@commons/backend/graphql/shared/dual-mode-patient-key.js';
import { normalizeDualModeKey } from '@commons/backend/graphql/shared/dual-mode-patient-key.js';
import { MemberModelV2Switch } from '@commons/backend/lib/member-model-v2-switch.js';
```

### 3.2 Update Loader Definition

```typescript
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

Key changes:

- Add type parameters: `<DualModePatientKey, ModelName, DualModePatientKey>`
- Change batch function to new `loadByPatient` method
- Update id function to return `DualModePatientKey` with switch check
- Add `normalizeDualModeKey` as third argument

---

## Phase 4: Caller Updates

### 4.1 Find All Callers

```bash
rg "xxxForPatient\.load" -t ts
```

### 4.2 Update Each Caller

**Basic update (most common):**

```typescript
// BEFORE
context.dataLoaders.xxxForPatient.load(patientId)
context.dataLoaders.xxxForPatient.load(root.id)

// AFTER
context.dataLoaders.xxxForPatient.load({ patientId })
context.dataLoaders.xxxForPatient.load({ patientId: root.id })
```

**With enrollmentId (when available):**

```typescript
// When caller has access to enrollmentId
context.dataLoaders.xxxForPatient.load({
  patientId: patient.id,
  enrollmentId: patient.activeEnrollmentId,
})
```

---

## Phase 5: Testing

### 5.1 Locate or Create Test File

Tests should be co-located with the model:

```
commons-packages/backend/models/{model-name}/__tests__/{model-name}.spec.ts
```

Or if model is in root models directory:

```
commons-packages/backend/models/__tests__/{model-name}.spec.ts
```

### 5.2 Add Tests with describeDualMode

```typescript
import { describeDualMode } from '@commons/backend/__tests__/helpers/member-model-v2-switch-test-helper.js';

describeDualMode('loadByPatient', () => {
  it('should load items for a single patient', async () => {
    // Test implementation
  });

  it('should load items for multiple patients', async () => {
    // Test implementation
  });

  it('should not return deleted items', async () => {
    // Test implementation
  });

  it('should return empty array for empty keys array', async () => {
    const items = await ModelName.loadByPatient([]);
    expect(items).toHaveLength(0);
  });

  it('should return empty array for patient with no items', async () => {
    // Test implementation
  });
});
```

---

## Phase 6: Validation

### 6.1 Run TypeScript Check

```bash
npm run typecheck
```

Note: This can take 10+ minutes in the Commons monorepo.

### 6.2 Run Tests

```bash
# Run specific test file
npm test commons-packages/backend/models/{model-name}/__tests__/{model-name}.spec.ts

# Or run model tests
npm test -- --testPathPattern="model-name"
```

### 6.3 Verify All Callers Work

Ensure no TypeScript errors in caller files.

---

## Troubleshooting

### "Property 'withDualModePatientKeys' does not exist"

Model doesn't use `PatientEnrollmentRelatedClassMixin`. Add it:

```typescript
import { Mixin } from 'ts-mixer';
import { PatientEnrollmentRelatedClassMixin } from '@commons/backend/models/patient-enrollment/patient-enrollment-related.js';

export default class ModelName extends Mixin(BaseModel, PatientEnrollmentRelatedClassMixin) { ... }
```

### "Type 'string' is not assignable to type 'DualModePatientKey'"

Caller not updated. Change from `.load(patientId)` to `.load({ patientId })`.

### Tests fail in one switch mode but not the other

Check that:

- `id` function correctly returns key based on `MemberModelV2Switch.shouldApplyEnrollmentLogic()`
- Test data has `patientEnrollmentId` set when testing enrollment mode

---

## Summary

After completing all phases, you should have:

1. New `loadByPatient` method in model using `withDualModePatientKeys`
2. Updated loader definition with dual-mode types and normalization
3. All callers updated to pass `{ patientId }` objects
4. Tests with `describeDualMode` wrapper
5. Typecheck passing
6. Tests passing
