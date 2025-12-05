# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /api-docs/v1/swagger.yaml' do
  it 'returns valid YAML' do
    get '/api-docs/v1/swagger.yaml'
    expect { YAML.parse(last_response.body) }.not_to raise_error
  end

  it 'has info about the art museum endpoint' do
    get '/api-docs/v1/swagger.yaml'
    open_api_spec = YAML.safe_load(last_response.body)
    expect(open_api_spec['paths'].keys).to include '/search/artmuseum'
  end

  it 'returns a 200' do
    get '/api-docs/v1/swagger.yaml'
    expect(last_response).to be_successful
  end
end
