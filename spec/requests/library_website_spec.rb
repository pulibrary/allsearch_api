# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/website' do
  before do
    stub_website(query: 'alma', fixture: 'library_website/alma.json')
  end

  it 'removes block-level HTML tags from the description field' do
    get '/search/website?query=alma'

    data = JSON.parse(response.body, symbolize_names: true)
    expect(data[:records][1][:description]).to include('Book Loans Borrowers may check out a maximum of 25 items.')
  end

  it 'converts &nbsp; to just a space in the description field' do
    get '/search/website?query=alma'

    data = JSON.parse(response.body, symbolize_names: true)
    expect(data[:records][1][:description]).to include(
      'Borrowers may check out a maximum of 25 items. Items are loaned for 4 weeks.'
    )
    expect(data[:records][1][:description]).not_to include('&nbsp;')
  end

  context 'when the upstream gives a 503 error' do
    before do
      url = 'https://library.princeton.edu/ps-library/search/results'
      stub_request(:post, url)
        .with(body: { 'search' => 'root' })
        .to_return(status: 503)
      allow(Honeybadger).to receive(:notify)
    end

    it 'gives the user a 500 error and a descriptive message' do
      get '/search/website?query=root'
      expect(response).to have_http_status(:internal_server_error)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq({
                                   problem: 'UPSTREAM_ERROR',
                                   message: 'The library website API returned a 503 HTTP status code.'
                                 })
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
