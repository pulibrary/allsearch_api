# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /' do
  it 'renders json' do
    get '/'
    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
    response_body = JSON.parse(response.body, symbolize_names: true)
    expect(response_body[:application]).to eq('Princeton University Library All Search API')
    expect(response_body[:environment]).to eq('test')
    expect(response_body[:github_link]).to eq('https://github.com/pulibrary/allsearch_api')
    expect(response_body[:documentation]).to eq('https://allsearch-api.princeton.edu/api-docs')
  end
end
