# frozen_string_literal: true

require "rails/generators"

module GeoblacklightAdmin
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies GBL Admin initializer files to host config
       5. Copies database.yml connection to host config
       5. Copies settings.yml to host config
       6. Copies .env.development and .env.test to host
       6. Copies JSON Schema to host
       7. Copies solr/* to host
       8. Sets Routes
       9. Sets Gems
       11.Sets DB Seeds
       11.Sets ActiveStorage
       12.Sets Pagy Backend

    DESCRIPTION

    def create_gbl_admin_initializer_files
      copy_file "config/initializers/geoblacklight_admin.rb", "config/initializers/geoblacklight_admin.rb", force: true
      copy_file "config/initializers/devise.rb", "config/initializers/devise.rb", force: true
      copy_file "config/initializers/kithe.rb", "config/initializers/kithe.rb", force: true
      copy_file "config/initializers/mime_types.rb", "config/initializers/mime_types.rb", force: true
      copy_file "config/initializers/pagy.rb", "config/initializers/pagy.rb", force: true
      copy_file "config/initializers/simple_form.rb", "config/initializers/simple_form.rb", force: true
      copy_file "config/initializers/simple_form_bootstrap.rb", "config/initializers/simple_form_bootstrap.rb", force: true
      copy_file "config/initializers/statesman.rb", "config/initializers/statesman.rb", force: true
    end

    def create_database_yml
      copy_file "config/database.yml", "config/database.yml", force: true
    end

    def create_settings_yml
      copy_file "config/settings.yml", "config/settings.yml", force: true
    end

    def create_dotenv
      copy_file ".env.development.example", ".env.development"
      copy_file ".env.development.example", ".env.test"
    end

    def copy_json_schema
      copy_file "config/geomg_aardvark_schema.json", "config/geomg_aardvark_schema.json"
    end

    def copy_solr
      directory "solr", "solr", force: true
    end

    def create_solr_yml
      copy_file ".solr_wrapper.yml", ".solr_wrapper.yml", force: true
    end

    def set_routes
      gbl_admin_routes = <<-"ROUTES"
  ####################
  # GBL‡ADMIN
  
  # Users
  devise_for :users, controllers: {invitations: "devise/invitations"}, skip: [:registrations]
  as :user do
    get "/sign_in" => "devise/sessions#new" # custom path to login/sign_in
    get "/sign_up" => "devise/registrations#new", :as => "new_user_registration" # custom path to sign_up/registration
    get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
    put "users" => "devise/registrations#update", :as => "user_registration"
  end

  mount GeoblacklightAdmin::Engine => '/'
      ROUTES

      inject_into_file "config/routes.rb", gbl_admin_routes, before: /^end/
    end

    def set_seeds
      append_to_file "db/seeds.rb" do
        "GeoblacklightAdmin::Engine.load_seed"
      end
    end

    def add_pagy
      inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
        "  include Pagy::Backend\n" \
      end
    end

    def add_activestorage
      append_to_file "app/assets/javascripts/application.js" do
        "

// Required by GBL Admin
//= require activestorage"
      end
    end

    def add_user_util_links
      copy_file "_user_util_links.html.erb", "app/views/shared/_user_util_links.html.erb"
    end

    def add_show_sidebar
      copy_file "_show_sidebar.html.erb", "app/views/catalog/_show_sidebar.html.erb"
    end

    # @TODO
    # I'm certain this is not the best way to inject our JS behaviors into the root app
    # But for now, this will do...
    # Long term I hope to avoid webpack here altogether.
    def copy_app_javascript
      directory "javascript", "app/javascript", force: true
    end

    def add_package_json
      copy_file "package.json", "package.json", force: true
    end

    def add_assets_initialier
      append_to_file "config/initializers/assets.rb" do
        "
        # GBL ADMIN
        Rails.application.config.assets.paths << Rails.root.join('node_modules')
        Rails.application.config.assets.precompile += %w( geoblacklight_admin.js )
        Rails.application.config.assets.precompile += %w[application.js]"
      end
    end

    def add_catalog_controller_default_params
      inject_into_file "app/controllers/catalog_controller.rb", after: '"q.alt" => "*:*"' do
        ",\n      'fq' => ['b1g_publication_state_s:published']"
      end
    end
  end
end
