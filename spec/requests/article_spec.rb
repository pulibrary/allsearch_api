# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/article' do
  before do
    stub_summon(query: 'forest', fixture: 'article/forest.json')
  end

  it 'returns json' do
    get '/search/article?query=forest'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end
end
