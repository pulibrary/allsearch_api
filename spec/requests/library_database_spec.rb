# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/database' do
  let(:libjobs_response) { file_fixture('libjobs/library-databases.csv') }
  let(:expected_record_keys) { [:title, :id, :type, :description, :url, :other_fields] }
  let(:expected_response) do
    {
      number: 3,
      records: [
        title: 'Oxford Music Online',
        id: '2939886',
        type: 'Database',
        description: 'Biographical articles for composers, performers, librettists, conductors and others. ' \
                     'Includes entries from Grove dictionaries of jazz and opera as well.',
        url: 'https://libguides.princeton.edu/resource/3970',
        other_fields: {
          subjects: 'Biographical Sources, Dance, Music, Music Literature, Theater',
          alternative_titles: 'Grove Music Online (now part of Oxford Music Online), ' \
                              'New Grove Dictionary of Music and Musicians (now part of Oxford Music Online)'
        }
      ]
    }
  end

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/library-databases.csv')
      .to_return(status: 200, body: libjobs_response)
    LibraryDatabaseLoadingService.new.run
  end

  it 'returns json' do
    get '/search/database?query=oxford music'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  it 'can handle a query like `0%000`' do
    get '/search/database?query=0%000'
    expect(response).to be_successful
  end

  it 'returns three results' do
    get '/search/database?query=oxford music'

    expect(response).to be_successful
    response_body = JSON.parse(response.body, symbolize_names: true)
    expect(response_body.keys).to contain_exactly(:number, :more, :records)
    expect(response_body[:records].count).to eq(3)
  end

  # For the current expected sort, Oxford Music Online should be the first record returned
  # This test should be replaced by the pending test below
  # once we get more details on the current service sort
  it 'matches the expected first record' do
    get '/search/database?query=oxford music'
    response_body = JSON.parse(response.body, symbolize_names: true)
    expect(response_body[:records][0].keys).to match_array(expected_record_keys)
    expected_record_keys.each do |key|
      expect(response_body[:records][0][key]).to match(expected_response[:records].first[key])
    end
  end

  it 'matches the expected last record' do
    pending('Waiting for more insight into LibGuides search')
    get '/search/database?query=oxford music'

    expect(response_body[:records][3].keys).to match_array(expected_record_keys)
    expected_record_keys.each do |key|
      expect(response_body[:records][3][key]).to match(expected_response[:records].first[key])
    end
  end

  # This is the currently expected sort. This test should be replaced by the pending test below
  # once we get more details on the current service sort
  it 'has the currently expected sort' do
    get '/search/database?query=oxford music'

    response_body = JSON.parse(response.body, symbolize_names: true)
    expect(response_body[:records][0][:title]).to eq('Oxford Music Online')
    expect(response_body[:records][1][:title]).to eq('Oxford Scholarship Online:  Music')
    expect(response_body[:records][2][:title]).to eq('Oxford Bibliographies: Music')
  end

  it 'matches the sort of the current service' do
    pending('Waiting for more insight into LibGuides search')
    get '/search/database?query=oxford music'

    response_body = JSON.parse(response.body, symbolize_names: true)
    # The order from Libguides search https://libguides.princeton.edu/az/databases?q=oxford%20music
    expect(response_body[:records][0][:title]).to eq('Oxford Scholarship Online:  Music')
    expect(response_body[:records][1][:title]).to eq('Oxford Bibliographies: Music')
    expect(response_body[:records][2][:title]).to eq('Oxford Music Online')
  end

  context 'when the search query matches more than 3 results' do
    it 'displays the total number of matches' do
      get '/search/database?query=oxford'
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:number]).to eq(4)
    end

    it 'only includes the first three records' do
      get '/search/database?query=oxford'
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:records].count).to eq(3)
    end
  end

  context 'with html in the description' do
    let(:libjobs_response) { file_fixture('libjobs/library-databases-html.csv') }
    let(:description) do
      'Biographical articles for composers, performers, librettists, conductors and others. ' \
        'Includes entries from Grove dictionaries of jazz and opera as well.'
    end

    before do
      stub_request(:get, 'https://lib-jobs.princeton.edu/library-databases.csv')
        .to_return(status: 200, body: libjobs_response)
      LibraryDatabaseLoadingService.new.run
    end

    it 'removes html from the description' do
      get '/search/database?query=oxford music'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:records].first[:description]).to eq(description)
    end
  end
end
