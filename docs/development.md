## Run Project for Local Development

### Bundle
```bash
bundle install
```

### Create Database
```bash
psql postgres
DROP DATABASE geoblacklight_development;
CREATE DATABASE geoblacklight_development;
```

### Run Application
```bash
bundle exec rake geoblacklight:admin:server
```

### Lint App
```bash
standardrb .
standardrb --fix
```

### Test App
```bash
bundle exec rake ci
```