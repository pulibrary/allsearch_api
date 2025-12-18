# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContentSecurityPolicyMiddleware do
  it 'adds a content security policy header' do
    app = ->(_env) { [200, {}, ['great!']] }
    middleware = described_class.new(app)
    csp = middleware.call({})[1]['Content-Security-Policy']
    expect(csp).to eq(
      "script-src 'self'; object-src 'none'; " \
      'connect-src https://allsearch-api.princeton.edu https://allsearch-api-staging.princeton.edu; ' \
      "base-uri 'none'; frame-ancestors 'none'"
    )
  end
end
