# frozen_string_literal: true

# $ rails new gbl_admin -m https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/template.rb

gem "devise"
gem "blacklight", ">= 7.0", "< 8.0"
gem "blacklight_advanced_search"
gem "geoblacklight", ">= 4.0"
gem "geoblacklight_admin"

run "bundle install"

generate "blacklight:install", "--devise"
generate "geoblacklight:install", "--force"
generate "blacklight_advanced_search:install", "--force"
generate "geoblacklight_admin:install", "--force"

rake "db:migrate"
rake "db:seed"
