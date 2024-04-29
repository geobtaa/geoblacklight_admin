# frozen_string_literal: true

require "rails/generators"

class TestAppGenerator < Rails::Generators::Base
  source_root "./test/test_app_templates"

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application

  def add_gems
    gem "blacklight", "~> 7.0"
    gem "config"
    gem "geoblacklight", ">= 4.0"
    gem "pagy"
    gem "simple_form"

    copy_file "../lib/generators/geoblacklight_admin/templates/config/settings.yml", "config/settings.yml"

    Bundler.with_unbundled_env do
      run "bundle install"
    end
  end

  def run_simple_form_generator
    say_status("warning", "GENERATING SIMPLE FORM", :yellow)
    generate "simple_form:install", "--bootstrap"
  end

  def run_blacklight_generator
    say_status("warning", "GENERATING BLACKLIGHT", :yellow)
    generate "blacklight:install", "--devise"
  end

  def run_geoblacklight_generator
    say_status("warning", "GENERATING GEOBLACKLIGHT", :yellow)
    generate "geoblacklight:install", "--force"
  end

  def run_geoblacklight_admin_generator
    say_status("warning", "GENERATING GEOBLACKLIGHT ADMIN", :yellow)
    generate "geoblacklight_admin:install", "--force"
  end
end
