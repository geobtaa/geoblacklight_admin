# geoblacklight_admin

![CI](https://github.com/geobtaa/geoblacklight_admin/actions/workflows/ci.yml/badge.svg)

GeoBlacklight Admin is a [GeoBlacklight](https://github.com/geoblacklight/geoblacklight) plugin, built on [Kithe](https://github.com/sciencehistory/kithe), that provides a complex web-form for editing documents and an CSV-based import/export workflow for OpenGeoMetadata's [Aardvark schema](https://opengeometadata.org/ogm-aardvark/). GBL Admin is based on the Big Ten Academic Alliance's production workflow tool [GEOMG](https://github.com/geobtaa/geomg).

[![GeoBlackliht Admin](https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/docs/gbl_admin_screenshot.png)](https://youtu.be/lWjcr-Ow228 "GeoBlacklight Admin")

## Requirements

* Rails v7
* Blacklight v7 (not v8)
* GeoBlacklight v4.4+ (Vite.js)
* @geoblacklight/frontend v4 (NPM package)
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

Use Ruby v3.3 and Rails v7.0.8.1 to bootstrap a new GeoBlacklight + GBL Admin application using the template script:

```bash
rails _7.0.8.1_ new gbl_admin -m https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/template.rb
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

## Contributing

For Developer documentation see [doc/developer.md](./docs/development.md)

## License
The gem is available as open source under the terms of the [Apache 2.0 License](https://opensource.org/license/apache-2-0).


## TODOs
* ~~Send GBLADMIN JavaScript pack to NPM like Blacklight~~
* DRY up Engine routing
* Remove legacy GEOMG / B1G everywhere...
* Likely some more polish to be uncovered...
