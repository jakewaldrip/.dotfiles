---
name: document-type-adding
description: When adding a new document type to the DocuSign integration
---

# Adding Document Types

When adding a new document type to the DocuSign integration, update 7 files following the pattern below.

## Required Information

Before starting, collect from the user:
- **Human-readable display label** (e.g., "Member Agreement for Benzodiazepine Therapy") - convert this to camelCase for the document type name unless instructed otherwise
- **Dev template ID** (UUID format, e.g., `1d692585-d6d6-49d6-b6c8-b6fa070050c0`)
- **Production template ID** (UUID format, e.g., `5d87e302-439e-4b0b-b8b0-5264cb05c65e`)
- **Preview URL** (Google Docs link or similar)
- **Market availability** - Ask if the document should be available for all markets or only specific markets (e.g., only NYC, only North Carolina, etc.)

## Default Assumptions

Unless instructed otherwise:
- Document type name will be the display label converted to camelCase
- Document will only support English (no Spanish or other languages)
- Document should be available across **all markets**
- Document should be an **additional document** (not required), added to `getAdditionalDocumentTypes`

## Files to Update

### 1. Add Document Type Enum Entry

**File:** [document-type-options.enum.ts](mdc:commons/shared/graphql/enums/document-type-options.enum.ts)

Add the new document type to the `DocumentTypeOptions` object (alphabetically positioned):

```typescript
documentTypeName: 'documentTypeName',
```

### 2. Add Dev Template ID Configuration

**File:** [docusign-document-configuration-default.ts](mdc:commons/server/models/helpers/docusign-document-configuration-default.ts)

Add to `DOCUMENT_TYPE_DOCUSIGN_MAPPING_DEFAULT` (alphabetically positioned):

```typescript
documentTypeName: {
  english: 'uuid-for-dev-template',
},
```

### 3. Add Production Template ID Configuration

**File:** [docusign-document-configuration-prod.ts](mdc:commons/server/models/helpers/docusign-document-configuration-prod.ts)

Add to `DOCUMENT_TYPE_DOCUSIGN_MAPPING_PROD` (alphabetically positioned):

```typescript
documentTypeName: {
  english: 'uuid-for-prod-template',
},
```

### 4. Add Human-Readable Display Label

**File:** [en.ts](mdc:commons/shared/messages/en.ts)

Add to the document type messages section (alphabetically positioned, around line ~3290):

```typescript
'documentType.documentTypeName': 'Human Readable Display Name',
```

### 5. Add Message Key Mapping

**File:** [helpers-docusign.ts](mdc:commons/app/patient-profile-container/documents/helpers-docusign.ts)

Add to `PATIENT_DOCUMENT_MESSAGE_IDS` (alphabetically positioned):

```typescript
[DocumentTypeOptions.documentTypeName]: 'documentType.documentTypeName',
```

### 6. Add Document to Market Availability List

**File:** [document-templates-helper.ts](mdc:commons/app/patient-profile-container/documents/document-templates-helper.ts)

If the document should be **available for all markets**, add to the `getAdditionalDocumentTypes` function in the main array (alphabetically positioned):

```typescript
'documentTypeName',
```

If the document should be **market-specific**, add it within a conditional spread similar to the North Carolina or Massachusetts examples:

```typescript
...(patientMarket === MARKET_SLUG
  ? ['documentTypeName']
  : []),
```

If the document should be a **required document**, add it to the `getRequiredDocumentTypes` function instead.

### 7. Add Preview URL

**File:** [market-document-links.ts](mdc:commons/shared/market-document-links.ts)

Add the document's preview URL to the `allFormsDriveUrls` function (alphabetically positioned).

For documents available across **all markets**:

```typescript
documentTypeName: {
  english: {
    url: 'https://docs.google.com/document/d/...',
  },
},
```

For **market-specific** documents:

```typescript
documentTypeName: {
  'market-slug': {
    english: {
      url: 'https://docs.google.com/document/d/...',
    },
  },
},
```

For **multi-language** documents, add additional language keys following the pattern of `treatmentConsent` or `phiReleaseAuthorization`.

## Important Notes

- All entries should be added alphabetically to maintain consistency
- Use camelCase for document type names (auto-convert from display label)
- Single-language documents (English only) follow the pattern of `refusalOfTreatment`
- Multi-language documents follow the pattern of `memberAppConsentAttestation` with additional language keys
- Market-specific documents use the market slug as a key (e.g., `'new-york-city'`, `'north-carolina'`, `'massachusetts'`)
- The preview URL in `market-document-links.ts` enables the "Preview document" button in the UI
