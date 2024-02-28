# frozen_string_literal: true

require "rails/generators"

module GeoblacklightAdmin
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies GBL Admin initializer files to host config
       2. Copies database.yml connection to host config
       3. Copies sidekiq.yml connection to host config
       4. Copies settings.yml to host config
       5. Copies .env.development and .env.test to host
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
      copy_file "config/initializers/shrine.rb", "config/initializers/shrine.rb", force: true
      copy_file "config/initializers/simple_form.rb", "config/initializers/simple_form.rb", force: true
      copy_file "config/initializers/simple_form_bootstrap.rb", "config/initializers/simple_form_bootstrap.rb", force: true
      copy_file "config/initializers/statesman.rb", "config/initializers/statesman.rb", force: true
    end

    def create_database_yml
      copy_file "config/database.yml", "config/database.yml", force: true
    end

    def create_sidekiq_yml
      copy_file "config/sidekiq.yml", "config/sidekiq.yml", force: true
    end

    def create_dotenv
      copy_file ".env.development.example", ".env.development"
      copy_file ".env.development.example", ".env.test"
    end

    def create_settings_yml
      copy_file "config/settings.yml", "config/settings.yml", force: true
    end

    def create_solr_yml
      copy_file ".solr_wrapper.yml", ".solr_wrapper.yml", force: true
    end

    def copy_json_schema
      copy_file "config/geomg_aardvark_schema.json", "config/geomg_aardvark_schema.json"
    end

    def copy_solr
      directory "solr", "solr", force: true
    end

    def set_routes
      gbl_admin_routes = <<-ROUTES
        ####################
        # GBL‡ADMIN

        # Bulk Actions
        resources :bulk_actions do
          patch :run, on: :member
          patch :revert, on: :member
        end

        # Users
        devise_for :users, controllers: {invitations: "devise/invitations"}, skip: [:registrations]
        as :user do
          get "/sign_in" => "devise/sessions#new" # custom path to login/sign_in
          get "/sign_up" => "devise/registrations#new", :as => "new_user_registration" # custom path to sign_up/registration
          get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
          put "users" => "devise/registrations#update", :as => "user_registration"
        end

        namespace :admin do
          # Root
          root to: "documents#index"

          # Bulk Actions
          resources :bulk_actions do
            patch :run, on: :member
            patch :revert, on: :member
          end

          # Imports
          resources :imports do
            resources :mappings
            resources :import_documents, only: [:show]
            patch :run, on: :member
          end

          # Elements
          resources :elements do
            post :sort, on: :collection
          end

          # Form Elements
          resources :form_elements do
            post :sort, on: :collection
          end
          resources :form_header, path: :form_elements, controller: :form_elements
          resources :form_group, path: :form_elements, controller: :form_elements
          resources :form_control, path: :form_elements, controller: :form_elements
          resources :form_feature, path: :form_elements, controller: :form_elements

          # Notifications
          resources :notifications do
            put "batch", on: :collection
          end

          # Users
          get "users/index"

          # Bookmarks
          resources :bookmarks
          delete "/bookmarks", to: "bookmarks#destroy", as: :bookmarks_destroy_by_fkeys

          # Search controller
          get "/search" => "search#index"
          
          # AdvancedSearch controller
          get '/advanced_search' => 'advanced_search#index', constraints: lambda { |req| req.format == :json }
          get '/advanced_search/facets' => 'advanced_search#facets', constraints: lambda { |req| req.format == :json }
          get '/advanced_search/facet/:id' => 'advanced_search#facet', constraints: lambda { |req| req.format == :json }, as: 'advanced_search_facet'

          # Ids controller
          get '/api/ids' => 'ids#index', constraints: lambda { |req| req.format == :json }
          get '/api' => 'api#index', constraints: lambda { |req| req.format == :json }
          get '/api/fetch' => 'api#fetch', constraints: lambda { |req| req.format == :json }
          get '/api/facet/:id' => 'api#facet', constraints: lambda { |req| req.format == :json }

          # Documents
          resources :documents do
            get "versions"

            # DocumentAccesses
            resources :document_accesses, path: "access" do
              collection do
                get "import"
                post "import"

                get "destroy_all"
                post "destroy_all"
              end
            end

            # DocumentDownloads
            resources :document_downloads, path: "downloads" do
              collection do
                get "import"
                post "import"

                get "destroy_all"
                post "destroy_all"
              end
            end

            # Document Assets
            resources :document_assets, path: "assets" do
              collection do
                get "display_attach_form"
                post "attach_files"

                get "destroy_all"
                post "destroy_all"
              end
            end

            collection do
              get "fetch"
            end
          end

          # Document Accesses
          resources :document_accesses, path: "access" do
            collection do
              get "import"
              post "import"

              get "destroy_all"
              post "destroy_all"
            end
          end

          # Document Downloads
          resources :document_downloads, path: "downloads" do
            collection do
              get "import"
              post "import"

              get "destroy_all"
              post "destroy_all"
            end
          end

          # Document Assets
          resources :document_assets, path: "assets" do
            collection do
              get "display_attach_form"
              post "attach_files"

              get "destroy_all"
              post "destroy_all"
            end
          end

          get "/documents/:id/ingest", to: "document_assets#display_attach_form", as: "asset_ingest"
          post "/documents/:id/ingest", to: "document_assets#attach_files"
          mount Kithe::AssetUploader.upload_endpoint(:cache) => "/direct_upload", :as => :direct_app_upload

          resources :collections, except: [:show]

          # Note "assets" is Rails reserved word for routing, oops. So we use
          # asset_files.
          resources :assets, path: "asset_files", except: [:new, :create] do
            member do
              put "convert_to_child_work"
            end
          end

          # @TODO
          # mount Qa::Engine => "/authorities"
          mount ActionCable.server => "/cable"

          # @TODO
          # authenticate :user, ->(user) { user } do
            # mount Blazer::Engine, at: "blazer"
          # end
        end
      ROUTES

      inject_into_file "config/routes.rb", gbl_admin_routes, before: /^end/
    end

    def set_development_mailer_host
      mailer_host = "\n  config.action_mailer.default_url_options = { :host => 'localhost:3000' }\n"
      inject_into_file "config/environments/development.rb", mailer_host, after: "config.action_mailer.perform_caching = false"
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
//= require activestorage
//= require geoblacklight_admin"
      end
    end

    def add_api_controller
      copy_file "api_controller.rb", "app/controllers/admin/api_controller.rb"
    end

    def add_user_util_links
      copy_file "_user_util_links.html.erb", "app/views/shared/_user_util_links.html.erb"
    end

    def copy_catalog_index_view
      copy_file "views/_index_split_default.html.erb", "app/views/catalog/_index_split_default.html.erb"
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

    def copy_app_images
      copy_file "images/bookmark-regular.svg", "app/assets/images/bookmark-regular.svg"
      copy_file "images/bookmark-solid.svg", "app/assets/images/bookmark-solid.svg"
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
        Rails.application.config.assets.precompile += %w[application.js]
        Rails.application.config.assets.precompile += %w[application.css]"
      end
    end

    def add_kithe_bulk_loading_service
      prepend_to_file "app/controllers/catalog_controller.rb" do
        "require 'kithe/blacklight_tools/bulk_loading_search_service'\n\n"
      end

      inject_into_file "app/controllers/catalog_controller.rb", after: "include Blacklight::Catalog" do
        "\n  self.search_service_class = Kithe::BlacklightTools::BulkLoadingSearchService"
      end
    end

    def add_kithe_model_to_solr_document
      inject_into_file "app/models/solr_document.rb", after: "include Geoblacklight::SolrDocument" do
        "\n\nattr_accessor :model"
      end
    end

    def add_search_builder_publication_state_concern
      inject_into_file "app/models/search_builder.rb", after: "include Geoblacklight::SuppressedRecordsSearchBehavior" do
        "\n      include GeoblacklightAdmin::PublicationStateSearchBehavior"
      end
    end

    def add_import_id_facet
      inject_into_file "app/controllers/catalog_controller.rb", before: "# Item Relationship Facets" do
        "\nconfig.add_facet_field Settings.FIELDS.B1G_IMPORT_ID, label: 'Import ID', show: false\n"
      end
    end
  end
end
