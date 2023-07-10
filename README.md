# geoblacklight_admin

GeoBlacklight Admin is a [GeoBlacklight](https://github.com/geoblacklight/geoblacklight) plugin, built on [Kithe](https://github.com/sciencehistory/kithe), that provides a complex web-form for editing documents and an CSV-based import/export workflow for OpenGeoMetadata's [Aardvark schema](https://opengeometadata.org/ogm-aardvark/). It's a Rubygem port of the Big Ten Academic Alliance's production workflow tool [GEOMG](https://github.com/geobtaa/geomg).

## Warning: Pre-Alpha

> :warning: This gem is not ready for public adoption yet, but hopefully someday soon (Late Summer 2023?). Feel free to kick the tires if you are curious and know GeoBlacklight's codebase/stack well.

## Requirements

* Blacklight v7 (not v8)
* GeoBlacklight v4 (not v3)
* Solr v8.4+
* PostgreSQL (not MySQL-based DBs)
* Redis (for Sidekiq)
* OpenGeoMetadata's Aardvark Schema

## Install Notes

### Terminal 1 - Drop/Create application PG database
```bash
psql postgres
DROP DATABASE geoblacklight_development;
CREATE DATABASE geoblacklight_development;
```

### Terminal 2

#### Bundle and run generator
```bash
bundle install
bundle exec rake engine_cart:generate
```

#### Seed and spin up server
```bash
cd .internal_test_app
bundle exec rake db:seed

# Run the app server
bundle exec rake gbl_admin:server
```

You're now done generating the test app and populating the Elements / FormElements tables with the basic Aardvark controls.

### View App in Browser

1. Visit http://localhost:3000/admin
2. Click on the "Sign in" link
3. Enter email: admin@geoblacklight.org and password: 123456
4. Click on the "GBL Admin" link
5. Import some CSV

-----

### TODOs - Running list of things to accomplish

* ~~SolrWrapper - Add persist option~~
* ~~BlacklightApi returns not auth'd message (not requiring auth for now (not sensitive data))~~
* ~~Facet links need /admin nesting~~
* ~~Imports#new -- undefined method `imports_path'~~
* ~~Elements#index -- undefined method `element_path'~~
* ~~Imports#new -- cannot upload files~~
* ~~Import#run -- doesn't fire~~
* ~~Documents - JS actions not working~~
* ~~GBL needs to honor publication state~~
* ~~Add GBL Admin link to nav~~
* ~~Routes - Get devise user~~
* ~~No route matches [GET] "/users/sign_out"~~
* ~~Bookmarks need to be Admin::Bookmarks~~
* GitHub Actions / CI integration
* Port the GEOMG test suite
* Remove legacy GEOMG / B1G everywhere...
* Send GBLADMIN JavaScript pack to NPM like Blacklight
* Project gem dependency injection redundancy...
* Likely a lot more polish to be uncovered...


## To Run Project
drop and create databases (or engine_cart will fail)
cd project root
bundle exec rake engine_cart:regenerate

### Run Solr
bin/rails geoblacklight:solr

### Run App
cd .internal_test_app
bundle exec rails server

### Test App
bundle exec rails test
cd .internal_test_app
bundle exec rake db:seed
bundle exec rake geomg:solr:reindex

## TODOs
* @TODO: Add chosen.js css
* @TODO: Fix missing select form-control class
