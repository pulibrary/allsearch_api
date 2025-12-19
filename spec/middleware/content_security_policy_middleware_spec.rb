# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentSecurityPolicyMiddleware do
  it 'adds a content security policy header' do
    app = ->(_env) { [200, {}, ['great!']] }
    middleware = described_class.new(app)
    csp = middleware.call({})[1]['Content-Security-Policy']
    expect(csp).to eq(
      "script-src 'self' 'unsafe-inline' https://unpkg.com; style-src 'self' 'unsafe-inline' https://unpkg.com; " \
      "object-src 'none'; " \
      'connect-src https://allsearch-api.princeton.edu https://allsearch-api-staging.princeton.edu ' \
      'http://localhost:3000; ' \
      "base-uri 'none'; frame-ancestors 'none'"
    )
  end
end
