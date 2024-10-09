## Run Project for Local Development

### Bundle
```bash
bundle install
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