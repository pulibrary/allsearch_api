# frozen_string_literal: true

require 'spec_helper'

describe HostHeaderMiddleware do
  it 'rejects request with a completely irrelevant Host header' do
    middleware = described_class.new(->(_env) { [200, {}, ['great!']] })
    env = { 'HTTP_HOST' => 'attacker.bad.com' }
    expect(middleware.call(env)).to eq [403, {}, ['Invalid host header']]
  end

  it 'logs rejections' do
    logger = instance_double(SemanticLogger::Logger, info: true)
    middleware = described_class.new(->(_env) { [200, {}, ['great!']] }, logger:)
    env = { 'HTTP_HOST' => 'attacker.bad.com' }

    middleware.call(env)

    expect(logger).to have_received(:info).with(
      'Rejected request from invalid host header',
      { host_header_in_request: 'attacker.bad.com', valid_domains: ['example.org'] }
    )
  end

  it 'rejects request with a non-numeric port in host header' do
    middleware = described_class.new(->(_env) { [200, {}, ['great!']] })
    env = { 'HTTP_HOST' => 'localhost:abc123bad' }
    expect(middleware.call(env)).to eq [403, {}, ['Invalid host header']]
  end

  it 'allows localhost request for development' do
    middleware = described_class.new(lambda { |_env|
      [200, {}, ['great!']]
    }, current_environment: Environment.new({ 'APP_ENV' => 'development' }))
    env = { 'HTTP_HOST' => 'localhost:3333' }
    expect(middleware.call(env)).to eq [200, {}, ['great!']]
  end

  it 'allows example.org request for test' do
    middleware = described_class.new(lambda { |_env|
      [200, {}, ['great!']]
    }, current_environment: Environment.new({ 'APP_ENV' => 'test' }))
    env = { 'HTTP_HOST' => 'example.org' }
    expect(middleware.call(env)).to eq [200, {}, ['great!']]
  end

  it 'allows allsearch-api.princeton.edu request for production' do
    middleware = described_class.new(lambda { |_env|
      [200, {}, ['great!']]
    }, current_environment: Environment.new({ 'APP_ENV' => 'production' }))
    env = { 'HTTP_HOST' => 'allsearch-api.princeton.edu' }
    expect(middleware.call(env)).to eq [200, {}, ['great!']]
  end

  it 'allows allsearch-api-staging.princeton.edu request for staging' do
    middleware = described_class.new(lambda { |_env|
      [200, {}, ['great!']]
    }, current_environment: Environment.new({ 'APP_ENV' => 'staging' }))
    env = { 'HTTP_HOST' => 'allsearch-api-staging.princeton.edu' }
    expect(middleware.call(env)).to eq [200, {}, ['great!']]
  end
end
