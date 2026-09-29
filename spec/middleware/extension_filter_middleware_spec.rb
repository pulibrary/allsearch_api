# frozen_string_literal: true

require 'spec_helper'

describe ExtensionFilterMiddleware do
   it 'rejects request with a non-json or yaml file extension' do
    middleware = described_class.new(->(_env) { [200, {}, ['great!']] })
    env = { 'PATH_INFO' => 'GET /search/article?query=test.dkq' }
    expect(middleware.call(env)).to eq [403, {}, ['Invalid URL']]
  end

  it 'does not reject .json extensions' do
    middleware = described_class.new(->(_env) { [200, {}, ['great!']] })
    env = { 'PATH_INFO' => 'GET /search/article?query=test.json' }
    expect(middleware.call(env)).to eq [200, {}, ['great!']]
  end

  it 'does not reject .yaml extensions' do
    middleware = described_class.new(->(_env) { [200, {}, ['great!']] })
    env = { 'PATH_INFO' => 'GET /search/article?query=test.yaml' }
    expect(middleware.call(env)).to eq [200, {}, ['great!']]
  end
end
