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
# Inject geoblacklight_admin dependencies
def inject_geoblacklight_admin_dependencies
  require 'bundler'
  gemspec_path = File.join(File.dirname(__FILE__), 'geoblacklight_admin.gemspec')
  if File.exist?(gemspec_path)
    gemspec = Bundler.load_gemspec(gemspec_path)
    gemspec.runtime_dependencies.each do |dep|
      # Skip if the dependency is already declared
      next if gem_already_declared?(dep.name)
      
      if dep.requirements_list.any?
        gem dep.name, *dep.requirements_list
      else
        gem dep.name
      end
    end
  else
    say "Warning: Could not find geoblacklight_admin.gemspec", :yellow
  end
end

def gem_already_declared?(name)
  # Check if gem is already declared in template
  File.readlines(__FILE__).any? { |line| line.match?(/^\s*gem\s+["']#{name}["']/) }
end

inject_geoblacklight_admin_dependencies

run "bundle install"

generate "blacklight:install", "--devise"
generate "geoblacklight:install", "--force"
generate "blacklight_advanced_search:install", "--force"
generate "geoblacklight_admin:install", "--force"

rake "db:migrate"
rake "db:seed"
