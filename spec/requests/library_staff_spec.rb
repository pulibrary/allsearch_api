# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/staff' do
  let(:libjobs_response) { file_fixture('library_staff/staff-directory.csv') }
  let(:expected_record_keys) { [:title, :id, :type, :url, :other_fields] }
  let(:expected_response) do
    {
      number: 3,
      records: [
        title: 'Trout, Nimbus',
        id: 00_0000_002,
        type: 'Library Staff',
        url: 'https://library.princeton.edu/staff/nimbuskt',
        other_fields: {
          building: 'Firestone Library',
          department: 'Library - Office of the Deputy University Librarian',
          email: 'nibmus@princeton.edu',
          first_name: 'Nimbus',
          last_name: 'Trout',
          library_title: 'Nap Coordinator',
          middle_name: 'Kilgore',
          office: 'A-200',
          phone: '(555) 111-1111',
          netid: 'nimbuskt'
        }
      ]
    }
  end

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/staff-directory.csv')
      .to_return(status: 200, body: libjobs_response)
    LibraryStaffLoadingService.new.run
  end

  it 'returns json' do
    get '/search/staff?query=lucy'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  it 'returns two results' do
    get '/search/staff?query=Firestone'

    expect(response).to be_successful
    response_body = JSON.parse(response.body, symbolize_names: true)
    expect(response_body.keys).to contain_exactly(:number, :more, :records)
    expect(response_body[:records].count).to eq(2)
  end

  it 'matches the expected first record' do
    get '/search/staff?query=Firestone'
    response_body = JSON.parse(response.body, symbolize_names: true)

    expect(response_body[:records][0].keys).to match_array(expected_record_keys)
    expected_record_keys.each do |key|
      expect(response_body[:records][0][key]).to match(expected_response[:records].first[key])
    end
  end

  context 'when the search query matches more than 3 results' do
    it 'displays the total number of matches' do
      get '/search/staff?query=library'
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:number]).to eq(4)
    end

    it 'only includes the first three records' do
      get '/search/staff?query=library'
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:records].count).to eq(3)
    end
  end
end
