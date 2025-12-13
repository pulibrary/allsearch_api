# frozen_string_literal: true

require 'rack_helper'

RSpec.describe 'GET /search/staff' do
  let(:libjobs_response) { file_fixture('library_staff/staff-directory.csv') }
  let(:expected_record_keys) { [:title, :id, :type, :url, :other_fields] }
  let(:expected_response) do
    {
      number: 3,
      records: [
        title: 'Trout, Nimbus',
        id: '2',
        type: 'Library Staff',
        url: 'https://library.princeton.edu/about/staff-directory/nimbus-kilgore-trout',
        other_fields: {
          building: 'Firestone Library',
          department: 'Office of the Deputy Dean of Libraries',
          email: 'nibmus@princeton.edu',
          first_name: 'Nimbus Kilgore',
          last_name: 'Trout',
          library_title: 'Nap Coordinator',
          office: 'A-200',
          phone: '(555) 111-1111',
          unit: 'IT Operations and Digitization',
          netid: 'nimbuskt',
          pronouns: 'he/him'
        }
      ]
    }
  end

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
      .to_return(status: 200, body: libjobs_response)
    LibraryStaffLoadingService.new.run
  end

  it 'returns json' do
    get '/search/staff?query=lucy'

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('application/json; charset=utf-8')
  end

  it 'can handle a query like `0%000`' do
    get '/search/staff?query=0%000'
    expect(last_response).to be_successful
  end

  it 'returns results based on name and building' do
    get '/search/staff?query=Firestone'

    expect(last_response).to be_successful
    response_body = JSON.parse(last_response.body, symbolize_names: true)
    expect(response_body.keys).to contain_exactly(:number, :more, :records)
    expect(response_body[:records].count).to eq(3)
  end

  it 'matches the expected first record' do
    get '/search/staff?query=Firestone'
    response_body = JSON.parse(last_response.body, symbolize_names: true)

    expect(response_body[:records][1].keys).to match_array(expected_record_keys)
    expected_record_keys.each do |key|
      expect(response_body[:records][1][key]).to match(expected_response[:records].first[key])
    end
  end

  context 'with an accent in the name' do
    it 'does not raise an error' do
      get '/search/staff?query=%C3%89t+tu'

      expect(last_response).to be_successful
      response_body = JSON.parse(last_response.body, symbolize_names: true)
      expect(response_body[:records].count).to eq(1)
    end
  end

  context 'when the search query matches more than 3 results' do
    it 'displays the total number of matches' do
      get '/search/staff?query=library'
      response_body = JSON.parse(last_response.body, symbolize_names: true)
      expect(response_body[:number]).to eq(5)
    end

    it 'only includes the first three records' do
      get '/search/staff?query=library'
      response_body = JSON.parse(last_response.body, symbolize_names: true)
      expect(response_body[:records].count).to eq(3)
    end
  end
end
