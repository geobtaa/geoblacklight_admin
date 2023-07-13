# frozen_string_literal: true

GeoblacklightAdmin::Engine.routes.draw do
  # Bulk Actions
  resources :bulk_actions do
    patch :run, on: :member
    patch :revert, on: :member
  end

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
#{"  "}

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
