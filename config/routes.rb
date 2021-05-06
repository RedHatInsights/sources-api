Rails.application.routes.draw do
  # Disable PUT for now since rails sends these :update and they aren't really the same thing.
  def put(*_args); end

  routing_helper = Insights::API::Common::Routing.new(self)

  prefix = "api"
  if ENV["PATH_PREFIX"].present? && ENV["APP_NAME"].present?
    prefix = File.join(ENV["PATH_PREFIX"], ENV["APP_NAME"]).gsub(/^\/+|\/+$/, "")
  end

  get "/health", :to => "status#health"

  scope :as => :api, :module => "api", :path => prefix do
    routing_helper.redirect_major_version("v3.1", prefix)
    routing_helper.redirect_major_version("v2.0", prefix)
    routing_helper.redirect_major_version("v1.0", prefix)

    namespace :v3x1, :path => "v3.1" do
      get "/openapi.json", :to => "root#openapi"
      post "/graphql", :to => "graphql#query"
      post "/bulk_create", :to => "bulk_create#create"

      resources :application_types,           :only => [:index, :show] do
        resources :sources, :only => [:index]
        get "app_meta_data", :to => "app_meta_data#index"
      end
      resources :applications,                :only => [:create, :destroy, :index, :show, :update] do
        resources :authentications, :only => [:index]
        post "pause", :to => "applications#pause"
        post "unpause", :to => "applications#unpause"
      end
      resources :application_authentications, :only => [:create, :destroy, :index, :show, :update]
      resources :authentications,             :only => [:create, :destroy, :index, :show, :update]
      resources :endpoints,                   :only => [:create, :destroy, :index, :show, :update] do
        resources :authentications, :only => [:index]
      end
      resources :source_types,                :only => [:index, :show] do
        resources :sources, :only => [:index]
      end
      resources :sources,                     :only => [:create, :destroy, :index, :show, :update] do
        post "check_availability", :to => "sources#check_availability", :action => "check_availability"
        resources :application_types, :only => [:index]
        resources :applications,      :only => [:index]
        resources :authentications,   :only => [:index]
        resources :endpoints,         :only => [:index]
      end
      resources :app_meta_data, :only => [:index, :show,]
    end

    namespace :v3x0, :path => "v3.0" do
      get "/openapi.json", :to => "root#openapi"
      post "/graphql", :to => "graphql#query"

      resources :application_types,           :only => [:index, :show] do
        resources :sources, :only => [:index]
      end
      resources :applications,                :only => [:create, :destroy, :index, :show, :update] do
        resources :authentications, :only => [:index]
      end
      resources :application_authentications, :only => [:create, :destroy, :index, :show, :update]
      resources :authentications,             :only => [:create, :destroy, :index, :show, :update]
      resources :endpoints,                   :only => [:create, :destroy, :index, :show, :update] do
        resources :authentications, :only => [:index]
      end
      resources :source_types,                :only => [:index, :show] do
        resources :sources, :only => [:index]
      end
      resources :sources,                     :only => [:create, :destroy, :index, :show, :update] do
        post "check_availability", :to => "sources#check_availability", :action => "check_availability"
        resources :application_types, :only => [:index]
        resources :applications,      :only => [:index]
        resources :authentications,   :only => [:index]
        resources :endpoints,         :only => [:index]
      end
    end

    namespace :v2x0, :path => "v2.0" do
      get "/openapi.json", :to => "root#openapi"
      post "/graphql", :to => "graphql#query"

      resources :application_types,           :only => [:index, :show] do
        resources :sources, :only => [:index]
      end
      resources :applications,                :only => [:create, :destroy, :index, :show, :update] do
        resources :authentications, :only => [:index]
      end
      resources :application_authentications, :only => [:create, :destroy, :index, :show, :update]
      resources :authentications,             :only => [:create, :destroy, :index, :show, :update]
      resources :endpoints,                   :only => [:create, :destroy, :index, :show, :update] do
        resources :authentications, :only => [:index]
      end
      resources :source_types,                :only => [:index, :show] do
        resources :sources, :only => [:index]
      end
      resources :sources,                     :only => [:create, :destroy, :index, :show, :update] do
        post "check_availability", :to => "sources#check_availability", :action => "check_availability"
        resources :application_types, :only => [:index]
        resources :applications,      :only => [:index]
        resources :authentications,   :only => [:index]
        resources :endpoints,         :only => [:index]
      end
    end

    namespace :v1x0, :path => "v1.0" do
      get "/openapi.json", :to => "root#openapi"
      post "/graphql", :to => "graphql#query"

      resources :application_types, :only => [:index, :show] do
        resources :sources, :only => [:index]
      end
      resources :applications,      :only => [:create, :destroy, :index, :show, :update]
      resources :authentications,   :only => [:create, :destroy, :index, :show, :update]
      resources :endpoints,         :only => [:create, :destroy, :index, :show, :update] do
        resources :authentications, :only => [:index]
      end
      resources :source_types,    :only => [:index, :show] do
        resources :sources, :only => [:index]
      end
      resources :sources,         :only => [:create, :destroy, :index, :show, :update] do
        post "check_availability", :to => "sources#check_availability", :action => "check_availability"
        resources :application_types, :only => [:index]
        resources :applications,      :only => [:index]
        resources :authentications,   :only => [:index]
        resources :endpoints,         :only => [:index]
      end
    end
  end

  scope :as => :internal, :module => "internal", :path => "internal" do
    routing_helper.redirect_major_version("v1.0", "internal", :via => [:get])

    namespace :v1x0, :path => "v1.0" do
      resources :authentications, :only => [:show]
      resources :tenants,         :only => [:index, :show]
    end
  end
end
