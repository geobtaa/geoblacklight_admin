# Upgrading

## 0.4.2

* Copy migration for `reference_types` table
* Copy migration for `documents_references` table
* Seed the `reference_types` table
* Mimetypes need to be updated in the application
* New routes for reference types and documents references
* Solr schema changes - new copyfield for database index auditing
* Migrate existing `dct_reference_s` values to the new `document_reference` table
  * `rake geoblacklight_admin:references:migrate`
* Audit the references migration
