# frozen_string_literal: true

require "rails/generators"

module GeoblacklightAdmin
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies GBL Admin initializer file to host config 
       2. Copies Kithe initializer file to host config
       3. Copies Pagy initializer file to host config
       4. Copies Statesman initializer file to host config
       5. Copies PG database.yml connection to host config
       6. Copies .env.development to host
       7. Copies solr/* to host
       8. Sets Routes
       9. Sets Gems
       10.Sets MimeTypes
       11.Sets DB Seeds
       12.Sets Pagy Backend

    DESCRIPTION

    def create_gbl_admin_initializer
      copy_file "config/initializers/geoblacklight_admin.rb", "config/initializers/geoblacklight_admin.rb"
    end

    def create_kithe_initializer
      copy_file "config/initializers/kithe.rb", "config/initializers/kithe.rb"
    end

    def create_pagy_initializer
      copy_file "config/initializers/pagy.rb", "config/initializers/pagy.rb"
    end

    def create_statesman_initializer
      copy_file "config/initializers/statesman.rb", "config/initializers/statesman.rb"
    end

    def create_database_yml
      copy_file "config/database.yml", "config/database.yml", force: true
    end

    def create_dotenv
      copy_file ".env.development.example", ".env.development"
    end

    def copy_json_schema
      copy_file "config/geomg_aardvark_schema.json", "config/geomg_aardvark_schema.json"
    end

    def copy_solr
      directory 'solr', 'solr', force: true
    end

    def create_solr_yml
      copy_file ".solr_wrapper.yml", ".solr_wrapper.yml", force: true
    end

    def set_routes
      gbl_admin_routes = <<-"ROUTES"
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
          #mount Kithe::AssetUploader.upload_endpoint(:cache) => "/direct_upload", :as => :direct_app_upload
        
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

    def set_gems
      append_to_file "Gemfile" do
        "
# GBL‡ADMIN
gem 'active_storage_validations', '~> 1.0'
gem 'blacklight_advanced_search'
# gem 'devise', '~> 4.7'
gem 'devise-bootstrap-views', '~> 1.0'
gem 'devise_invitable', '~> 2.0'
gem 'dotenv-rails'
gem 'httparty'
gem 'inline_svg'
gem 'kithe'
gem 'noticed'
gem 'pagy'
gem 'paper_trail'
gem 'simple_form'
        "
      end
    end

    def set_mime_types
      append_to_file "config/initializers/mime_types.rb" do
        '
# GBL‡ADMIN
# Order is important. ActiveStorage needs :json to be last
Mime::Type.register "application/json", :json_aardvark
Mime::Type.register "application/json", :json_btaa_aardvark
Mime::Type.register "application/json", :json_gbl_v1
Mime::Type.register "application/json", :json
Mime::Type.register "text/csv", :csv_document_downloads
Mime::Type.register "text/csv", :csv_document_access_links
        '
      end
    end

    def set_seeds
      append_to_file "db/seeds.rb" do
        'GeoblacklightAdmin::Engine.load_seed'
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
  end
end
