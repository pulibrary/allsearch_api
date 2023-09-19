# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/libanswers' do
  before do
    stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token')
      .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
      .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
    stub_request(:get, 'https://faq.library.princeton.edu/api/1.1/search/printer?iid=344&limit=3')
      .with(
        headers: {
          'Authorization' => 'Bearer abcdef1234567890abcdef1234567890abcdef12'
        }
      )
      .to_return(status: 200, body: file_fixture('libanswers/printer.json'))
  end

  it 'returns json' do
    get '/search/libanswers?query=printer'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    let(:expected_response) do
      { number: 2,
        more: 'https://faq.library.princeton.edu/search/?t=0&q=printer',
        records: [
          { title: 'Color printer?',
            url: 'https://faq.library.princeton.edu/faq/11559',
            id: '11559',
            type: 'FAQ',
            other_fields: {
              topics: 'Library Information and Policies and Technology'
            } }, {
              title: 'Printing from laptop to a library printer?',
              url: 'https://faq.library.princeton.edu/econ/faq/11210',
              id: '11210',
              type: 'FAQ',
              other_fields: {
                topics: 'Technical issues'
              }
            }
        ] }
    end

    it 'can take a parameter' do
      get '/search/libanswers?query=printer'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body.keys).to contain_exactly(:number, :more, :records)
      expect(response_body[:number]).to eq(expected_response[:number])
      expect(response_body[:more]).to eq(expected_response[:more])
      expect(response_body[:records].first.keys).to contain_exactly(:title, :id, :type, :url,
                                                                    :other_fields)
      expect(response_body[:records]).to match(expected_response[:records])
    end
  end
end
