# frozen_string_literal: true

# $ rails new gbl_admin -m https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/template.rb

gem "devise"
gem "blacklight", ">= 7.0", "< 8.0"
gem "geoblacklight", ">= 4.0"
gem "geoblacklight_admin"

# GBL‡ADMIN
gem 'active_storage_validations'
gem 'awesome_print'
gem 'blacklight_advanced_search'
gem 'dotenv-rails'
gem 'haml'
gem 'inline_svg'
gem 'kithe', '~> 2.0'
gem 'noticed'
gem 'paper_trail'

run "bundle install"

generate "blacklight:install", "--devise"
generate "geoblacklight:install", "--force"
generate "blacklight_advanced_search:install", "--force"
generate "geoblacklight_admin:install", "--force"

rake "db:migrate"
rake "db:seed"
