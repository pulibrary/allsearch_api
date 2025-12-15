# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'app/paths'

require allsearch_path 'init/environment'
require allsearch_path 'init/honeybadger'
require allsearch_path 'init/logger'

require_relative 'config/environment'
require allsearch_path 'config/allsearch_configs'
require allsearch_path 'app/router'

use Rack::Cors do
  allow do
    origins %r{\Ahttp://localhost(:\d+)?\Z},
            %r{\Ahttp://127.0.0.1(:\d+)?\Z},
            %r{\Ahttps://[\w-]+\.princeton.edu\Z}

    resource '/search/*', headers: :any, methods: [:get, :head]
    resource '/banner', headers: :any, methods: [:get, :head]
  end
end
use ExceptionHandlerMiddleware
use LoggerMiddleware
use HostHeaderMiddleware
use Rack::Static, urls: { '/api-docs/v1/swagger.yaml' => '/swagger/v1/swagger.yaml' }
use Rack::Head
use Rack::ConditionalGet
use Rack::ETag
use Rack::UTF8Sanitizer, sanitize_null_bytes: true

run Rails.application.config.middleware.build(Router)
Rails.application.load_server
