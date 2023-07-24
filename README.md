# geoblacklight_admin

![CI](https://github.com/geobtaa/geoblacklight_admin/actions/workflows/ci.yml/badge.svg)

GeoBlacklight Admin is a [GeoBlacklight](https://github.com/geoblacklight/geoblacklight) plugin, built on [Kithe](https://github.com/sciencehistory/kithe), that provides a complex web-form for editing documents and an CSV-based import/export workflow for OpenGeoMetadata's [Aardvark schema](https://opengeometadata.org/ogm-aardvark/). GBL Admin is based on the Big Ten Academic Alliance's production workflow tool [GEOMG](https://github.com/geobtaa/geomg).

[![GeoBlackliht Admin](https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/docs/gbl_admin_screenshot.png)](https://youtu.be/lWjcr-Ow228 "GeoBlacklight Admin")

## Requirements

* Rails v6.1 (not v7 yet)
* Blacklight v7 (not v8)
* GeoBlacklight v4 (not v3)
* Solr v8.4+
* PostgreSQL (not MySQL-based DBs)
* Redis (for Sidekiq)
* OpenGeoMetadata's Aardvark Schema

## Installation

### PostgreSQL

You need a PostgreSQL database to use this project.

* Homebrew: https://wiki.postgresql.org/wiki/Homebrew
* Docker: https://www.docker.com/blog/how-to-use-the-postgres-docker-official-image/

### Install Template

Use Ruby v3.2 and Rails v6.1.7.4 to bootstrap a new GeoBlacklight + GBL Admin application using the template script:

```bash
rails _6.1.7.4_ new gbl_admin -m https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/template.rb
cd gbl_admin
bundle exec rake gbl_admin:server
```

You have now generated the .internal_test_app and populated the Elements / FormElements tables for OMG Aardvark support.

### View App in Browser

1. Visit http://localhost:3000/admin
2. Click on the "Sign in" link
3. Enter email: admin@geoblacklight.org and password: 123456
4. Click on the "GBL Admin" link
5. Import some CSV (test/fixtures/files/btaa_sample_records.csv)

-----

## Run Project for Local Development
Drop and recreate databases (or engine_cart:generate will fail)

### Drop/Create application PG database
```bash
psql postgres
DROP DATABASE geoblacklight_development;
CREATE DATABASE geoblacklight_development;
```

```bash
cd project root
bundle install
bundle exec rake engine_cart:regenerate
```

### Run Solr
```bash
bin/rails geoblacklight:solr
```

### Run App
```bash
cd .internal_test_app
bundle exec rails server
```

### Lint App
```bash
standardrb .
```

### Test App
```bash
RAILS_ENV=test bundle exec rails test
```

## TODOs
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
* ~~GitHub Actions / CI integration~~
* ~~Port the GEOMG test suite~~
* ~~Project gem dependency injection redundancy...~~
* DRY up Engine routing
* Remove legacy GEOMG / B1G everywhere...
* Send GBLADMIN JavaScript pack to NPM like Blacklight
* Likely some more polish to be uncovered...
