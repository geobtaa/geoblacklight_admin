# frozen_string_literal: true

# $ rails new gbl_admin -m https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/wip-dry-routing/template.rb

gem "devise"
gem 'devise_invitable', '~> 2.0.0'
gem "blacklight", ">= 7.0", "< 8.0"
gem "blacklight_advanced_search"
gem "geoblacklight", ">= 4.0"
gem "geoblacklight_admin"

run "bundle install"

generate "devise:install"
generate "devise_invitable:install"
generate "blacklight:install"
generate "geoblacklight:install", "--force"
generate "blacklight_advanced_search:install", "--force"
generate "geoblacklight_admin:install", "--force"

rake "db:migrate"
rake "db:seed"
