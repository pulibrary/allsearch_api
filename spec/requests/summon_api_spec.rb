# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/summon' do
  before do
    stub_summon(query: 'forest', fixture: 'summon_api/summon_response.json')
  end

  it 'returns json' do
    get '/search/summon?query=forest'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end
end
