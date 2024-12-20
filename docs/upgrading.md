# Upgrading

## Steps for v0.6.0 upgrade

This release includes a significant number of changes to the GBL Admin application. Principally, the introduction of the `document_distributions` table to replace the `dct_references_s` field in the `documents` table. This change moves us from a single CSV file workflow to a multi-file CSV workflow. One CSV file is used to create the `documents` table and one or more CSV files are used to create the `document_distributions` table.

### Application Changes

This is a list of manual changes that need to be made to the parent Rails application to successfully upgrade from v0.5.0 to v0.6.0.

#### COPY MIGRATIONS

* Copy migration for `reference_types` table
* Copy migration for `documents_references` table
* Copy migration to rename `documents_references` to `document_distributions`

#### SEED REFERENCE TYPES

* Seed the `reference_types` table

#### MIMETYPE UPDATE

* Update the mime type configuration in the application (config/initializers/mime_types.rb)

#### ROUTES

* New routes for reference types and document distributions

#### ENV VAR

* Set env var for `GBL_ADMIN_REFERENCES_MIGRATED` to `false`

#### DATA MIGRATION

* In the Elements table, update the "References" element's import and export functions to distributions_json (from `references_json`)
* Migrate existing AttrJson `dct_reference_s` values to the new `document_distributions` table
  * `rake geoblacklight_admin:distributions:migrate`
* Audit the distributions migration
  * `rake geoblacklight_admin:distributions:audit`
* Set environment variable for `GBL_ADMIN_DISTRIBUTIONS_MIGRATED` to `true`
