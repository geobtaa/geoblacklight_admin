# frozen_string_literal: true

# $ rails _7.0.4.2_ new gbl_admin -m https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/template.rb

gem "blacklight", ">= 7.0", "< 8.0"
gem "geoblacklight", ">= 4.0"
gem "geoblacklight_admin"

run "bundle install"

generate "blacklight:install", "--devise"
generate "geoblacklight:install", "--force"
generate "blacklight_advanced_search:install", "--force"
generate "geoblacklight_admin:install", "--force"

rake "db:migrate"
rake "db:seed"
