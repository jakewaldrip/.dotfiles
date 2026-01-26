---
name: add-document-type
description: Add new document types to the DocuSign integration in the Commons monorepo. Use when the user wants to add a patient document, consent form, or agreement to the DocuSign workflow.
---

# Add Document Type to DocuSign

## Prerequisites

Collect from user before starting:
- **Display label** (e.g., "Member Agreement for Benzodiazepine Therapy")
- **Dev template ID** (UUID)
- **Production template ID** (UUID)
- **Preview URL** (Google Docs link)
- **Market availability** (all markets or specific markets?)

## Defaults

Unless instructed otherwise:
- Document type name = display label → camelCase
- English only
- Available in **all markets**
- Added as **additional document** (not required)

## Process

Update these 7 files (all entries **alphabetically sorted**):

### 1. Add Enum Entry

**File:** `commons-packages/shared/graphql/enums/document-type-options.enum.ts`

```typescript
documentTypeName: 'documentTypeName',
```

### 2. Add Dev Template ID

**File:** `commons-packages/shared/docusign/docusign-document-configuration-default.ts`

```typescript
documentTypeName: {
  english: 'dev-template-uuid',
},
```

### 3. Add Production Template ID

**File:** `commons-packages/shared/docusign/docusign-document-configuration-prod.ts`

```typescript
documentTypeName: {
  english: 'prod-template-uuid',
},
```

### 4. Add Display Label

**File:** `commons-packages/shared/messages/en.ts` (around line ~3290)

```typescript
'documentType.documentTypeName': 'Human Readable Display Name',
```

### 5. Add Message Key Mapping

**File:** `commons-packages/frontend/patient-profile-container/documents/helpers-docusign.ts`

```typescript
[DocumentTypeOptions.documentTypeName]: 'documentType.documentTypeName',
```

### 6. Add to Market Availability

**File:** `commons-packages/frontend/patient-profile-container/documents/document-templates-helper.ts`

**All markets** — add to `getAdditionalDocumentTypes`:
```typescript
'documentTypeName',
```

**Market-specific** — add within conditional spread:
```typescript
...(patientMarket === 'market-slug' ? ['documentTypeName'] : []),
```

**Required documents** — add to `getRequiredDocumentTypes` instead.

### 7. Add Preview URL

**File:** `commons-packages/shared/market-document-links.ts`

**All markets:**
```typescript
documentTypeName: {
  english: { url: 'https://docs.google.com/document/d/...' },
},
```

**Market-specific:**
```typescript
documentTypeName: {
  'market-slug': {
    english: { url: 'https://docs.google.com/document/d/...' },
  },
},
```

**Multi-language:** Follow `treatmentConsent` or `phiReleaseAuthorization` patterns.

## Reference

- Market slugs: `'new-york-city'`, `'north-carolina'`, `'massachusetts'`
- Single-language pattern: `refusalOfTreatment`
- Multi-language pattern: `memberAppConsentAttestation`
