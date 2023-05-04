require "rails/generators"

module GeoblacklightAdmin
  class Install < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc "Install GeoblacklightAdmin"

    def add_settings_vars
    end

    def bundle_install
      Bundler.with_unbundled_env do
        run "bundle install"
      end
    end

    def generate_gbl_admin_assets
      inject_into_file "app/assets/stylesheets/application.scss", after: "@import 'geoblacklight';\n" do
        "@import 'geoblacklight_admin/core';"
      end
    end

    def generate_gbl_admin_example_docs
      generate "geoblacklight_admin:example_docs"
    end

    def generate_gbl_admin_jobs
      generate "geoblacklight_admin:jobs"
    end

    def generate_gbl_admin_models
      generate "geoblacklight_admin:models"
    end

    def generate_gbl_admin_views
      generate "geoblacklight_admin:views"
    end

    def generate_gbl_admin_helpers
      generate "geoblacklight_admin:helpers"
    end

    def generate_gbl_admin_config
      generate "geoblacklight_admin:config"
    end

    def kithe_install
      run "bundle exec rails generate simple_form:install --bootstrap"
    end
  end
end
