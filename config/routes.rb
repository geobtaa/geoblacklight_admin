GeoblacklightAdmin::Engine.routes.draw do
  # GBL‡ADMIN
  resources :bulk_actions do
    patch :run, on: :member
    patch :revert, on: :member
  end

  # @TODO - Users
  # devise_for :users, controllers: {invitations: "devise/invitations"}, skip: [:registrations]
  # as :user do
  #  get "/sign_in" => "devise/sessions#new" # custom path to login/sign_in
  #  get "/sign_up" => "devise/registrations#new", :as => "new_user_registration" # custom path to sign_up/registration
  #  get "users/edit" => "devise/registrations#edit", :as => "edit_user_registration"
  #  put "users" => "devise/registrations#update", :as => "user_registration"
  # end

  namespace :admin do
    # Root
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
  
    # @TODO
    # mount Qa::Engine => "/authorities"
    mount ActionCable.server => "/cable"
  
    # @TODO
    # authenticate :user, ->(user) { user } do
      # mount Blazer::Engine, at: "blazer"
    # end
  end
end