---
name: react-component-library-usage
description: Guidelines for using the Commonplace Design System in React components
---

## Overview

This project uses the **Commonplace Design System**, Cityblock's comprehensive library of consistent, accessible, and well-tested components.

- Located at: `commons-packages/commonplace/`
- Import from: `@cityblock/commonplace`
- Documentation: [https://commonplace.design](https://commonplace.design)
- **Before building anything new**, check `commonplace.ts` and associated `.stories.tsx` files

## Usage Examples

```tsx
// Good - Using Commonplace components with slots
import { Card, VerticalStack, Text, Row, Tag, Button } from '$commons/app/shared/commonplace';

<Card
  title="Patient information"
  actions={<Button text="Edit" />}
  leftContent={<Tag text="Active" />}
  titleRowContent={<Tag text="High priority" />}
>
  <VerticalStack gap="medium">
    <Text element="p" text="Patient details content" />
    <Text element="p" text="Event description" />
  </VerticalStack>
</Card>

// Avoid - Custom styling, custom classes
<div style={{ padding: '16px', backgroundColor: '#f5f5f5' }}>
  <h2 style={{ fontSize: '18px' }}>Title</h2>
  <p class="mt-6">Content</p>
</div>
```

## Guidelines

- **Use Commonplace components** over raw HTML or custom elements
- **Customization priority**: Props → Slots → className → Wrappers → Never direct CSS
- **Don't edit component source** - customize through usage only
- **When components don't exist**: Search thoroughly, try composition, then propose new component

## Custom CSS

Only add custom CSS if the Commonplace component doesn't provide a prop to achieve the desired styling. Use existing CSS variables instead of custom px, em, rem, or hex values. For example:

```tsx
// component.tsx
import { Text } from '$commons/app/shared/commonplace';
import styles from './css/component.css'

<Text element="p" text="Item details" className={styles.details} />

// component.css
.details {
  color: var(--color-text-light);
  font-size: var(--font-size-body-sm);
  line-height: var(--line-height-body-sm);
}
```
