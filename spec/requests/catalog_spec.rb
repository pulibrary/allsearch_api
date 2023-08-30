# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/catalog' do
  it 'returns json' do
    get '/search/catalog?query=rubix'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    let(:expected_response) do
      { number: 7,
        more: 'https://catalog.princeton.edu/catalog?q=rubix&search_field=all_fields',
        records: [
          { title: "Rub'ix qatinamit = El canto del pueblo : Estudiantina del Instituto Indígena de Santiago " \
                   '/ [Oscar Azmitia, Manuel Salazar].',
            creator: 'Azmitia, Oscar',
            publisher: '[Guatemala] : El Instituto, [199-]',
            id: 'SCSB-11568989',
            type: 'Book',
            url: 'https://catalog.princeton.edu/catalog/SCSB-11568989',
            other_fields: {
              call_number: 'ML421.I55 A96 1990z',
              library: 'ReCAP'
            } }
        ] }
    end

    it 'can take a parameter' do
      get '/search/catalog?query=rubix'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body.keys).to match_array(%i[number more records])
      expect(response_body[:records].first.keys).to match_array(%i[title creator publisher id type url
                                                                   other_fields])
      expect(response_body[:records].first).to match(expected_response[:records].first)
    end

    it 'only returns the first three records' do
      get '/search/catalog?query=rubix'

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:records].size).to eq(3)
    end
  end

  context 'without a search term' do
    it 'returns a 400 bad request' do
      get '/search/catalog?query='

      expect(response).to be_bad_request

      #     response_body = JSON.parse(response.body, symbolize_names: true)

      #     expect(response_body).to eq(
      #       errors: {
      #         query: ["must be filled"]
      #       }
      #     )
    end
  end

  context 'without a publisher in records' do
    it 'does not raise the error NoMethodError' do
      get '/search/catalog?query=pangulubalang'

      expect(response).to be_successful
    end

    it 'does not include unused keys' do
      get '/search/catalog?query=pangulubalang'

      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:records].first.keys).to match_array(%i[title id type url other_fields])
    end
  end

  context 'with weird search strings' do
    it 'appropriately escapes the query' do
      get '/search/catalog?query=What if "I quote" my search?'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:records]).to be_empty
      expect(response_body[:more]).to eq('https://catalog.princeton.edu/catalog?q=What%20if%20%22I%20quote%22%20my%20search?&search_field=all_fields')
    end
  end

  context 'with CJK characters' do
    it 'matches the catalog search results' do
      # 触物生情话道南 is escaped after you put it in the browser - in the search bar it still shows as the
      # correct characters
      get '/search/catalog?query=%E8%A7%A6%E7%89%A9%E7%94%9F%E6%83%85%E8%AF%9D%E9%81%93%E5%8D%97'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body[:number]).to be(81)
    end
  end
end