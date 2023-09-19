# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/best-bet' do
  let(:google_response) { file_fixture('google_sheets/best_bets.csv') }
  let(:expected_response) do
    {
      number: 1,
      records: [
        title: 'The New York Times',
        id: 480,
        type: 'Electronic Resource',
        description: 'Guide with links to the best sources for current and historical full text online of the NYT.',
        url: 'http://libguides.princeton.edu/newspapers/usacurrent#nyt'
      ]
    }
  end
  let(:expected_record_keys) { [:title, :id, :type, :description, :url] }

  before do
    stub_request(:get, 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSSDYbAmj_SDVK96DJItSsir_PbjMIqe8cBMvBfRIh4fpVzv3aozhCdulrgJXZzwl-fh-lbULMuLZuO/pub?gid=170493948&single=true&output=csv')
      .to_return(status: 200, body: google_response)
    BestBetLoadingService.new.run
  end

  it 'returns json' do
    get '/search/best-bet?query=new york times'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  it 'can take a parameter' do
    get '/search/best-bet?query=new york times'
    expect(response).to be_successful
    response_body = JSON.parse(response.body, symbolize_names: true)

    expect(response_body.keys).to contain_exactly(:number, :records)
    expect(response_body[:records].first.keys).to match_array(expected_record_keys)
    # Since right now the ID is coming from the database, it will be different each time we run the test
    matching_record_keys = expected_record_keys - [:id]
    matching_record_keys.each do |key|
      expect(response_body[:records].first[key]).to match(expected_response[:records].first[key])
    end
  end
end
