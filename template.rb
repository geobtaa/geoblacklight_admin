# frozen_string_literal: true

##### INSTALL NOTES #####
#
# 1. Create your geoblacklight_admin_development PostgreSQL database
#
# $> psql postgres
# $> CREATE DATABASE geoblacklight_admin_development;
#
# 2. Run these lines below to stand up a new GBL + GBL Admin instance:
#
# $> rails _7.2.2_ new gbl_admin -m https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/template.rb
# $> cd gbl_admin
# $> bundle exec rake geoblacklight:server
#

# Core dependencies
gem "devise"
gem "blacklight", ">= 7.0", "< 8.0"
gem "geoblacklight", ">= 4.0"
gem "geoblacklight_admin", git: "git@github.com:geobtaa/geoblacklight_admin.git", branch: "develop"

# GBL‡ADMIN
# Add geoblacklight_admin runtime dependencies
gem "active_storage_validations", "~> 1.0"
gem "amazing_print"
gem "blacklight", "~> 7.0"
gem "blacklight_advanced_search"
gem "blacklight_range_limit"
gem "bootstrap", "~> 4.0"
gem "chosen-rails", "~> 1.10"
gem "cocoon", "~> 1.2"
gem "config", "~> 4.0"
gem "devise", "~> 4.7"
gem "devise-bootstrap-views", "~> 1.0"
gem "dotenv-rails", "~> 2.8"
gem "geoblacklight", "~> 4.0"
gem "haml", "~> 5.2"
gem "httparty", "~> 0.21"
gem "inline_svg", "~> 1.9"
gem "jquery-rails", "~> 4.4"
gem "kithe", "~> 2.0"
gem "mutex_m", "~> 0.2.0"
gem "noticed", "~> 1.6"
gem "pagy", "~> 9.0"
gem "paper_trail", "~> 15.0"
gem "pg", "~> 1.4"
gem "qa", "~> 5.0"
gem "ruby-progressbar"
gem "simple_form", "~> 5.0"
gem "sprockets", "~> 3.0"
gem "statesman", "~> 12.0"
gem "vite_rails", "~> 3.0"
gem "vite_ruby", ">= 3.5"
gem "zeitwerk", "~> 2.6"

run "bundle install"

generate "blacklight:install", "--devise"
generate "geoblacklight:install", "--force"
generate "blacklight_advanced_search:install", "--force"
generate "geoblacklight_admin:install", "--force"

rake "db:migrate"
rake "db:seed"
