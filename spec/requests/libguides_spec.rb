# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/libguides' do
  before do
    stub_request(:post, 'https://lgapi-us.libapps.com/1.2/oauth/token')
      .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
      .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
    stub_request(:get, 'https://lgapi-us.libapps.com/1.2/guides?expand=owner,subjects,tags&search_terms=Asian%20American%20studies&sort_by=relevance&status=1')
      .with(
        headers: {
          'Authorization' => 'Bearer abcdef1234567890abcdef1234567890abcdef12'
        }
      )
      .to_return(status: 200, body: file_fixture('libguides/asian_american_studies.json'))
  end

  it 'returns json' do
    get '/search/libguides?query=Asian+American+studies'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    let(:expected_response) do
      { number: 59,
        more: 'https://libguides.princeton.edu/srch.php?q=Asian American studies',
        records: [
          { title: 'Asian American Studies',
            type: 'General Purpose Guide',
            creator: 'Steven Knowlton',
            description: 'A guide to print and electronic resources in Princeton University Library.',
            publisher: 'Princeton University Library',
            url: 'https://libguides.princeton.edu/asianamericans',
            id: '84140',
            other_fields: {} }
        ] }
    end

    it 'can take a parameter' do
      get '/search/libguides?query=Asian+American+studies'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body.keys).to contain_exactly(:number, :more, :records)
      expect(response_body[:number]).to eq(expected_response[:number])
      expect(response_body[:more]).to eq(expected_response[:more])
      expect(response_body[:records].first).to match(expected_response[:records].first)
      expect(response_body[:records].count).to eq(3)
    end
  end
end
