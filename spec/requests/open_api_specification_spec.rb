# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /api-docs/v1/swagger.yaml' do
  it 'returns valid YAML' do
    get '/api-docs/v1/swagger.yaml'
    expect { YAML.parse(response.body) }.not_to raise_error
  end

  it 'has info about the art museum endpoint' do
    get '/api-docs/v1/swagger.yaml'
    open_api_spec = YAML.safe_load(response.body)
    expect(open_api_spec['paths'].keys).to include '/search/artmuseum'
  end

  it 'returns a 200' do
    get '/api-docs/v1/swagger.yaml'
    expect(response).to be_successful
  end
end
