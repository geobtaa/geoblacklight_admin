# $ rails _7.0.4.2_ new app-name -m https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/main/template.rb

gem "blacklight", ">= 7.0", "< 8.0"
gem "blacklight_advanced_search", "~> 7.0"
gem "geoblacklight", ">= 4.0"
gem "statesman", ">= 3.4"
gem "geoblacklight_admin"

run "bundle install"

generate "blacklight:install", "--devise"
generate "geoblacklight:install", "--force"
generate "blacklight_advanced_search:install", "--force"
generate "geoblacklight_admin:install", "--force"

rake "db:migrate"