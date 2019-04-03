Rails.application.routes.draw do
  # Disable PUT for now since rails sends these :update and they aren't really the same thing.
  def put(*_args); end

  prefix = "api"
  if ENV["PATH_PREFIX"].present? && ENV["APP_NAME"].present?
    prefix = File.join(ENV["PATH_PREFIX"], ENV["APP_NAME"]).gsub(/^\/+|\/+$/, "")
  end

  scope :as => :api, :module => "api", :path => prefix do
    match "/v0/*path", :via => [:delete, :get, :options, :patch, :post], :to => redirect(:path => "/#{prefix}/v0.1/%{path}", :only_path => true)

    namespace :v0x1, :path => "v0.1" do
      get "/openapi.json", :to => "root#openapi"
      resources :authentications, :only => [:create, :destroy, :index, :show, :update]
      resources :endpoints,       :only => [:create, :destroy, :index, :show, :update] do
        resources :authentications, :only => [:index]
      end
      resources :source_types,    :only => [:create, :index, :show] do
        resources :availabilities, :only => [:index]
        resources :sources,        :only => [:index]
      end
      resources :sources,         :only => [:create, :destroy, :index, :show, :update] do
        resources :availabilities, :only => [:index]
        resources :endpoints,      :only => [:index]
      end
    end
  end

  scope :as => :internal, :module => "internal", :path => "internal" do
    match "/v0/*path", :via => [:get], :to => redirect(:path => "/internal/v0.0/%{path}", :only_path => true)

    namespace :v0x1, :path => "v0.1" do
      resources :authentications, :only => [:show]
    end
  end
end
