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
        id: 2_939_886,
        type: 'Database',
        description: 'Biographical articles for composers, performers, librettists, conductors and others. ' \
                     'Includes entries from Grove dictionaries of jazz and opera as well.',
        url: 'https://libguides.princeton.edu/resource/3970',
        other_fields: {
          subjects: ['Biographical Sources', 'Dance', 'Music', 'Music Literature', 'Theater'],
          alternative_titles: ['Grove Music Online (now part of Oxford Music Online)',
                               'New Grove Dictionary of Music and Musicians (now part of Oxford Music Online)']
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

  it 'returns three results' do
    skip('Currently this test is flaky - it often passes but sometimes fails.' \
         'Will do another commit to fix this')
    get '/search/database?query=oxford music'

    expect(response).to be_successful
    response_body = JSON.parse(response.body, symbolize_names: true)
    expect(response_body.keys).to contain_exactly(:number, :more, :records)
    expect(response_body[:records].count).to eq(3)
    expect(response_body[:records].first.keys).to match_array(expected_record_keys)
    expected_record_keys.each do |key|
      expect(response_body[:records].first[key]).to match(expected_response[:records].first[key])
    end
  end

  it 'matches the sort of the current service' do
    skip('Currently this test is flaky - it often passes but sometimes fails.' \
         'Will do another commit to fix this')
    get '/search/database?query=oxford music'

    response_body = JSON.parse(response.body, symbolize_names: true)

    expect(response_body[:records][0][:title]).to eq('Oxford Music Online')
    expect(response_body[:records][1][:title]).to eq('Oxford Bibliographies: Music')
    expect(response_body[:records][2][:title]).to eq('Oxford Scholarship Online:  Music')
  end
end
