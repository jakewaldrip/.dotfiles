---
name: database-migration
description: Create a migration to add, remove, or edit columns, tables, or indexes in the database
---

## What I do

- Create database migrations
- Add or remove columns
- Add or remove indexes
- Add or remove tables

## When to use me

Use this when you are editing the database in any way. This can include adding, removing, or editing columns, tables, or indexes

## Context

We are using Postgres in a typescript backend. The migrations are written in typescript leveraging Knex

## Steps

1. Run `npm run migrate:make name-of-migration` in the shell, where `name-of-migration` is the name of the migration
2. Open this file and you will find a blank Knex migration
3. Search in `migrations/models/examples` for existing examples of what you are trying to do, and use this as a template for your migration
4. Fill the migration file in with your changes
