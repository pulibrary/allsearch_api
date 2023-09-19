# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/best-bet' do
  it 'returns json' do
    get '/search/best-bet?query=new york times'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end
end
