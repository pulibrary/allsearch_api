# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/summon' do
  it 'returns json' do
    pending('Completing the Summon service and document')
    get '/search/summon?query=potato'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end
end
