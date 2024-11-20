# Upgrading

## Steps for v0.5.0

### Database Migrations
* Copy migration for `reference_types` table
* Copy migration for `documents_references` table
* Copy migration to rename `documents_references` to `document_distributions`
* Seed the `reference_types` table

### Application Changes
* Mimetypes need to be updated in the application
* New routes for reference types and documents references
* Solr schema changes - new copyfield for database index auditing
* Set env var for `GBL_ADMIN_REFERENCES_MIGRATED` to `false`
* Migrate existing `dct_reference_s` values to the new `document_reference` table
  * `rake geoblacklight_admin:references:migrate`
* Audit the references migration
  * `rake geoblacklight_admin:references:audit`
* Set env var for `GBL_ADMIN_REFERENCES_MIGRATED` to `true`
