$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "geoblacklight_admin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "geoblacklight_admin"
  s.version = GeoblacklightAdmin::VERSION
  s.authors = ["Eric Larson"]
  s.email = ["ewlarson@gmail.com"]
  s.homepage = "https://github.com/geobtaa/geoblacklight_admin"
  s.summary = "Administrative UI for GeoBlacklight. Built on Kithe."
  s.license = "MIT"

  s.files = `git ls-files -z`.split(%(\x0))
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "config", "~> 4.0"
  s.add_dependency "chosen-rails", "1.0"
  s.add_dependency "devise", "~> 4.7"
  s.add_dependency "devise-bootstrap-views", "~> 1.0"
  s.add_dependency "devise_invitable", "~> 2.0"
  s.add_dependency "blacklight", "~> 7.33"
  s.add_dependency "blacklight_advanced_search"
  s.add_dependency "geoblacklight", "~> 4.0"
  s.add_dependency "httparty", "~> 0.21"
  s.add_dependency "inline_svg", "~> 1.9"
  s.add_dependency "kithe", "~> 2.0"
  s.add_dependency "noticed", "~> 1.6"
  s.add_dependency "pagy", "~> 3.8"
  s.add_dependency "paper_trail", "~> 14.0"
  s.add_dependency "pg", "~> 1.4"
  s.add_dependency "rails", ">= 6.1", "< 7.1"
  s.add_dependency "sprockets", "< 4"
  s.add_dependency "statesman", "~> 7.1.0"

  s.add_development_dependency "byebug", "~> 11.1"
  s.add_development_dependency "capybara", "~> 3.0"
  s.add_development_dependency "capybara-screenshot", "~> 1.0"
  s.add_development_dependency "database_cleaner", "~> 1.3"
  s.add_development_dependency "database_cleaner-active_record", "~> 2.1"
  s.add_development_dependency "engine_cart", "~> 2.4"
  s.add_development_dependency "m", "~> 1.5"
  s.add_development_dependency "minitest", "~> 5.18"
  s.add_development_dependency "minitest-ci", "~> 3.4"
  s.add_development_dependency "minitest-rails", "~> 6.1"
  s.add_development_dependency "minitest-reporters", "~> 1.6"
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "selenium-webdriver"
  s.add_development_dependency "shoulda-context", "~> 2.0"
  s.add_development_dependency "simplecov", "~> 0.22"
  s.add_development_dependency "solr_wrapper", "~> 4.0"
  s.add_development_dependency "sprockets", "< 4"
  s.add_development_dependency "standard", "~> 1.24"
  s.add_development_dependency "webdrivers"
end
