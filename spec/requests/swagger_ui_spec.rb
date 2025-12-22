# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GET /api-docs' do
  it 'has a DOM selector where the JS can mount the Swagger UI' do
    get '/api-docs'
    parsed = Nokogiri::HTML(last_response.body)
    expect(parsed.css('#swagger-ui')).to_not be_nil
  end

  it 'returns a 200' do
    get '/api-docs'
    expect(last_response).to be_successful
  end
end
