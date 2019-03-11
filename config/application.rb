require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TopologicalInventory
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Disabling eagerload in production in favor of autoload
    config.autoload_paths += config.eager_load_paths

    # NOTE:  If you are going to make changes to autoload_paths, please make
    # sure they are all strings.  Rails will push these paths into the
    # $LOAD_PATH.
    #
    # More info can be found in the ruby-lang bug:
    #
    #   https://bugs.ruby-lang.org/issues/14372
    #
    config.autoload_paths << Rails.root.join("app", "models", "mixins").to_s
    config.autoload_paths << Rails.root.join("app", "controllers", "mixins").to_s
    config.autoload_paths << Rails.root.join("lib").to_s

    ManageIQ::API::Common::Logging.activate(config)
    ManageIQ::API::Common::Metrics.activate(config, "topological_inventory_api")
  end
end
