# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'action_controller/railtie'
require 'active_record/railtie'
require 'action_view/railtie'

require_relative 'lando_env'
require_relative 'db_connection'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BentoRailsApi
  class Application < Rails::Application
    config.middleware.delete Rails::Rack::Logger
    config.middleware.delete Rack::Sendfile
    config.middleware.delete Rack::Runtime
    config.middleware.delete ActionDispatch::Static
    config.middleware.delete ActionDispatch::Executor
    config.middleware.delete ActionDispatch::ServerTiming
    config.middleware.delete ActiveSupport::Cache::Strategy::LocalCache::Middleware
    config.middleware.delete ActionDispatch::RequestId
    config.middleware.delete ActionDispatch::RemoteIp
    config.middleware.delete ActionDispatch::Reloader
    config.middleware.delete ActionDispatch::Callbacks
    config.middleware.delete Rack::Head
    config.middleware.delete Rack::ConditionalGet
    config.middleware.delete Rack::ETag
    config.middleware.delete ActionDispatch::HostAuthorization
    config.middleware.delete ActionDispatch::ShowExceptions
    config.middleware.delete ActionDispatch::DebugExceptions
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Use the sql format so that we can capture our postgres custom search configuration
    config.active_record.schema_format = :sql

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.hosts << 'allsearch-api-staging.princeton.edu'
    config.hosts << 'allsearch-api.princeton.edu'
    # Rack's mock responses use example.org
    config.hosts << 'example.org'
  end
end
