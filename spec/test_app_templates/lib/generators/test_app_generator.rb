# frozen_string_literal: true

require "rails/generators"

class TestAppGenerator < Rails::Generators::Base
  source_root "./test/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application

  def add_gems
    gem "blacklight", "~> 7.0"
    gem "geoblacklight", ">= 4.0"

    # GBL‡ADMIN
    gem "active_storage_validations"
    gem "awesome_print"
    gem "blacklight_advanced_search"
    gem "devise-bootstrap-views", "~> 1.0"
    gem "devise_invitable", "~> 2.0.0"
    gem "dotenv-rails"
    gem "haml"
    gem "inline_svg"
    gem "kithe", "~> 2.0"
    gem "noticed"
    gem "paper_trail"

    Bundler.with_unbundled_env do
      run "bundle install"
    end
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)
    generate "blacklight:install", "--devise"
  end

  def run_geoblacklight_generator
    say_status("warning", "GENERATING GBL", :yellow)
    generate "geoblacklight:install", "--force"
  end

  def run_geoblacklight_admin_generator
    say_status("warning", "GENERATING GBL Admin", :yellow)
    generate "geoblacklight_admin:install", "--force"
  end
end
