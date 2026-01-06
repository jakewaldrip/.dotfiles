---
name: feature-flag-create-or-remove
description: When creating or removing a new feature flag from the database
---

## Adding and Removing

- When adding a new feature flag to [feature-flags.enum.ts](mdc:commons/shared/graphql/enums/feature-flags.enum.ts), make sure you also add it to the database following the template migration [_feature-flag-create.ts](mdc:commons/server/models/migrations/examples/_feature-flag-create.ts)
- When removing feature flags, use the template migration [_feature-flag-remove.ts](mdc:commons/server/models/migrations/examples/_feature-flag-remove.ts) and delete the flag from [feature-flags.enum.ts](mdc:commons/shared/graphql/enums/feature-flags.enum.ts)
- When referencing a flag in a migration file, use a string instead of the enum value as the enum could change later.
- Follow the usual rules in [migrations.mdc](mdc:commons/.cursor/rules/migrations.mdc)

## Naming conventions

- Use camelCase for feature flag names
- Make names descriptive and specific to the feature they control
- Avoid generic names that could be ambiguous
- Ask the user to provide a team name to create the flag with
