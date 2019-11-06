Rails.application.routes.draw do
  # Disable PUT for now since rails sends these :update and they aren't really the same thing.
  def put(*_args); end

  routing_helper = ManageIQ::API::Common::Routing.new(self)

  prefix = "api"
  if ENV["PATH_PREFIX"].present? && ENV["APP_NAME"].present?
    prefix = File.join(ENV["PATH_PREFIX"], ENV["APP_NAME"]).gsub(/^\/+|\/+$/, "")
  end

  scope :as => :api, :module => "api", :path => prefix do
    routing_helper.redirect_major_version("v1.0", prefix)

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
      resources :source_types,    :only => [:create, :index, :show] do
        resources :sources, :only => [:index]
      end
      resources :sources,         :only => [:create, :destroy, :index, :show, :update] do
        resources :applications, :only => [:index]
        resources :application_types, :only => [:index]
        resources :endpoints, :only => [:index]
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
