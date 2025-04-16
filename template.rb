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

# Inject geoblacklight_admin dependencies
def inject_geoblacklight_admin_dependencies
  require 'open-uri'
  
  gemspec_url = "https://raw.githubusercontent.com/geobtaa/geoblacklight_admin/develop/geoblacklight_admin.gemspec"
  
  begin
    gemspec_content = URI.open(gemspec_url).read
    
    # Extract dependencies using regex instead of evaluating the gemspec
    dependencies = gemspec_content.scan(/^\s*s\.add_dependency\s*["']([^"']+)["'](,\s*["'][^"']+["'])?/)
    
    dependencies.each do |dep|
      name = dep[0]
      version = dep[1]&.gsub(/[",\s]/, '') # Clean up version constraint
      
      # Skip if the dependency is already declared
      next if gem_already_declared?(name)
      
      if version
        gem name, version
      else
        gem name
      end
    end
  rescue OpenURI::HTTPError => e
    say "Warning: Could not fetch gemspec from #{gemspec_url}: #{e.message}", :yellow
  rescue StandardError => e
    say "Warning: Error processing gemspec: #{e.message}", :yellow
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
