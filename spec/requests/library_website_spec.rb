# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/website' do
  context 'when the upstream gives a 503 error' do
    before do
      url = 'https://library.psb-prod.princeton.edu/ps-library/search/results'
      stub_request(:post, url)
        .with(body: { 'search' => 'root' })
        .to_return(status: 503)
    end

    it 'gives the user a 500 error and a descriptive message' do
      get '/search/website?query=root'
      expect(response).to have_http_status(:internal_server_error)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq({
                                   problem: 'UPSTREAM_ERROR',
                                   message: 'The library website API returned a 503 HTTP status code.'
                                 })
    end
  end
end
