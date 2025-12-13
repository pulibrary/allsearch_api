# frozen_string_literal: true

require 'rack_helper'

RSpec.describe 'GET /search/best-bet', :truncate do
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
  let(:response_body) { JSON.parse(last_response.body, symbolize_names: true) }
  let(:service_path) { 'best-bet' }

  before do
    stub_request(:get, 'https://docs.google.com/spreadsheets/d/e/2PACX-1vSSDYbAmj_SDVK96DJItSsir_PbjMIqe8cBMvBfRIh4fpVzv3aozhCdulrgJXZzwl-fh-lbULMuLZuO/pub?gid=170493948&single=true&output=csv')
      .to_return(status: 200, body: google_response)
    BestBetLoadingService.new.run
  end

  it_behaves_like 'a search controller'

  it 'returns json' do
    get '/search/best-bet?query=new york times'

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('application/json; charset=utf-8')
  end

  it 'can take a parameter' do
    get '/search/best-bet?query=new york times'
    expect(last_response).to be_successful
    expect(response_body.keys).to contain_exactly(:number, :records)
    expect(response_body[:records].count).to eq(1)
    expect(response_body[:records].first.keys).to match_array(expected_record_keys)
    # Since right now the ID is coming from the database, it will be different each time we run the test
    matching_record_keys = expected_record_keys - [:id]
    matching_record_keys.each do |key|
      expect(response_body[:records].first[key]).to match(expected_response[:records].first[key])
    end
  end

  it 'can handle a query like `0%000`' do
    get '/search/best-bet?query=0%000'
    expect(last_response).to be_successful
  end

  context 'with a partial entry' do
    let(:google_response) { file_fixture('google_sheets/best_bets_mid_edit.csv') }

    it 'continues to return only complete entries' do
      get '/search/best-bet?query=times'
      expect(last_response).to be_successful
      expect(response_body.keys).to contain_exactly(:number, :records)
      expect(response_body[:records].count).to eq(1)
    end
  end
end
