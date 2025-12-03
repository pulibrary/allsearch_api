# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /api-docs' do
  it 'has a DOM selector where the JS can mount the Swagger UI' do
    get '/api-docs'
    parsed = Nokogiri::HTML(response.body)
    expect(parsed.css('#swagger-ui')).to be_present
  end

  it 'returns a 200' do
    get '/api-docs'
    expect(response).to be_successful
  end
end
