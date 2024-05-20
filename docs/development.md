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
bin/rails server
```

### Lint App
```bash
standardrb .
standardrb --fix
```

### Test App
```bash
RAILS_ENV=test bundle exec rails test
```