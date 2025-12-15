# frozen_string_literal: true

# This middleware is responsible for guarding against attacks based on the
# HTTP Host header, such as DNS rebinding when running locally, or insecure
# use of the Host header within our application when deployed.
# See
# * https://portswigger.net/web-security/host-header
# * https://www.paloaltonetworks.com/cyberpedia/what-is-dns-rebinding
# * https://github.com/sinatra/sinatra/blob/main/rack-protection/lib/rack/protection/host_authorization.rb
# * https://github.com/rails/rails/blob/main/actionpack/lib/action_dispatch/middleware/host_authorization.rb
class HostHeaderMiddleware
  REJECTION = [403, {}, ['Invalid host header']].freeze
  VALID_DOMAINS_BY_ENVIRONMENT = {
    'production' => ['allsearch-api.princeton.edu'],
    'staging' => ['allsearch-api-staging.princeton.edu'],
    'development' => ['localhost', '127.0.0.1'],
    'test' => ['example.org']
  }.freeze

  def initialize(app, current_environment: CURRENT_ENVIRONMENT, logger: ALLSEARCH_LOGGER)
    @app = app
    @current_environment = current_environment
    @logger = logger
  end

  def call(env)
    domain, _delimiter, port = env['HTTP_HOST'].partition(':')
    if valid_domains.include?(domain) && (port !~ /\D/)
      app.call(env)
    else
      logger.info('Rejected request from invalid host header',
                  { host_header_in_request: env['HTTP_HOST'], valid_domains: })
      REJECTION
    end
  end

  private

  attr_reader :app, :current_environment, :logger

  def valid_domains
    @valid_domains ||= VALID_DOMAINS_BY_ENVIRONMENT[current_environment.name]
  end
end
