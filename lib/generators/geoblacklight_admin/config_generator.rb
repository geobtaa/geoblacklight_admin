# frozen_string_literal: true

require "rails/generators"

module GeoblacklightAdmin
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    desc <<-DESCRIPTION
      This generator makes the following changes to your application:
       1. Copies GBL Admin initializer file to host config 
       2. Copies Kithe initializer file to host config
       3. Copies Statesman initializer file to host config
       4. Copies PG database.yml connection to host config
       5. Copies .env.development to host
       6. Sets Routes
       7. Sets Gems
    DESCRIPTION

    def create_gbl_admin_initializer
      copy_file "config/initializers/geoblacklight_admin.rb", "config/initializers/geoblacklight_admin.rb"
    end

    def create_kithe_initializer
      copy_file "config/initializers/kithe.rb", "config/initializers/kithe.rb"
    end

    def create_statesman_initializer
      copy_file "config/initializers/statesman.rb", "config/initializers/statesman.rb"
    end

    def create_database_yml
      copy_file "config/database.yml", "config/database.yml"
    end

    def create_dotenv
      copy_file ".env.development.example", ".env.development"
    end

    def copy_json_schema
      copy_file "config/geomg_aardvark_schema.json", "config/geomg_aardvark_schema.json"
    end

    def set_routes
      gbl_admin_routes = <<-"ROUTES"
        # GBL‡ADMIN
        resources :bulk_actions do
          patch :run, on: :member
          patch :revert, on: :member
        end

        namespace :admin do
          root to: "documents#index"
          
          # AdvancedSearch controller
          get '/advanced_search' => 'advanced_search#index', constraints: lambda { |req| req.format == :json }
          get '/advanced_search/facets' => 'advanced_search#facets', constraints: lambda { |req| req.format == :json }
          get '/advanced_search/facet/:id' => 'advanced_search#facet', constraints: lambda { |req| req.format == :json }, as: 'advanced_search_facet'

          # Ids controller
          get '/api/ids' => 'ids#index', constraints: lambda { |req| req.format == :json }
          get '/api' => 'api#index', constraints: lambda { |req| req.format == :json }
          get '/api/fetch' => 'api#fetch', constraints: lambda { |req| req.format == :json }
          get '/api/facet/:id' => 'api#facet', constraints: lambda { |req| req.format == :json }

          resources :documents do
            get "versions"
        
            resources :document_accesses, path: "access" do
              collection do
                get "import"
                post "import"
        
                get "destroy_all"
                post "destroy_all"
              end
            end
        
            resources :document_downloads, path: "downloads" do
              collection do
                get "import"
                post "import"
        
                get "destroy_all"
                post "destroy_all"
              end
            end
        
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
        
          resources :document_accesses, path: "access" do
            collection do
              get "import"
              post "import"
        
              get "destroy_all"
              post "destroy_all"
            end
          end
        
          resources :document_downloads, path: "downloads" do
            collection do
              get "import"
              post "import"
        
              get "destroy_all"
              post "destroy_all"
            end
          end
        
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
        
          # mount Qa::Engine => "/authorities"
          mount ActionCable.server => "/cable"
        
          authenticate :user, ->(user) { user } do
            # mount Blazer::Engine, at: "blazer"
          end
        end
      ROUTES

      inject_into_file "config/routes.rb", gbl_admin_routes, before: /^end/
    end

    def set_gems
      append_to_file "Gemfile" do
        "
# GBL‡ADMIN
gem 'blacklight_advanced_search'
gem 'dotenv-rails'
gem 'httparty'
gem 'inline_svg'
gem 'pagy'
gem 'paper_trail'
gem 'kithe'
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
  end
end
