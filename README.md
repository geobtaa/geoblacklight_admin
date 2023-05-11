# geoblacklight_admin

### Install

* Install notes

Terminal 1
```bash
psql postgres
DROP DATABASE geoblacklight_development;
CREATE DATABASE geoblacklight_development;
```

Terminal 2
```bash
bundle install
bundle exec rake engine_cart:generate
```

Edit geoblacklight_admin_helper.rb, uncomment Pagy
```bash
  # @TODO:
  # Cannot generate app if uncommented...
  # Uncomment after app is generated to fix view errors
  # include ::Pagy::Frontend
```

Seed and spin up server
```bash
cd .internal_test_app; bundle exec rake db:seed
bundle exec rake gbl_admin:server
```

Done generating test app and populating Elements/FormElements

View App in Browser: http://localhost:3000/admin

-----

### TODOs

* ~~SolrWrapper - Add persist option~~
* ~~BlacklightApi returns not auth'd message (not requiring auth for now (not sensitive data))~~
* ~~Facet links need /admin nesting~~
* ~~Imports#new -- undefined method `imports_path'~~
* ~~Elements#index -- undefined method `element_path'~~
* ~~Imports#new -- cannot upload files~~
* ~~Import#run -- doesn't fire~~
* ~~Documents - JS actions not working~~

* GBL needs to honor publication state
* Bookmarks need to be Admin::Bookmarks
* Add Admin link to nav
* Routes - Get devise user
* Remove GEOMG everywhere...


Devise routes fail... have to add after generator to .internal-test-app

* No route matches [GET] "/users/sign_out"

