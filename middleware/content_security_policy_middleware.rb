# frozen_string_literal: true

class ContentSecurityPolicyMiddleware
  CSP_DIRECTIVES = [
    "script-src 'self'",
    "object-src 'none'",
    'connect-src https://allsearch-api.princeton.edu https://allsearch-api-staging.princeton.edu',
    "base-uri 'none'",
    "frame-ancestors 'none'"
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    response = app.call(env)
    [response[0], response[1].merge(content_security_policy_header), response[2]]
  end

  private

  def content_security_policy_header
    {
      'Content-Security-Policy' => CSP_DIRECTIVES.join('; ')
    }
  end

  attr_reader :app
end
