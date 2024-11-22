# Upgrading

## Steps for v0.5.0

### Application Changes
* COPY MIGRATION - Copy migration for `reference_types` table
* COPY MIGRATION - Copy migration for `documents_references` table
* COPY MIGRATION - Copy migration to rename `documents_references` to `document_distributions`
* SEED - Seed the `reference_types` table
* MIMETYPE - changes need to be updated in the application
* ROUTES - New routes for reference types and document distributions
* SOLR - Solr schema changes - new copyfield for database index auditing (?)
* ENV VAR - Set env var for `GBL_ADMIN_REFERENCES_MIGRATED` to `false`
* DB MIGRATE - Migrate existing `dct_reference_s` values to the new `document_reference` table
  * `rake geoblacklight_admin:references:migrate`
* DB AUDIT - Audit the references migration
  * `rake geoblacklight_admin:references:audit`
* ENV VAR - Set env var for `GBL_ADMIN_REFERENCES_MIGRATED` to `true`
* ELEMENTS - Update the References element import/export function to distributions_json
