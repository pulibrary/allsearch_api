# frozen_string_literal: true

require 'rack_helper'

RSpec.describe 'GET /search/findingaids' do
  let(:service_path) { 'findingaids' }

  before do
    stub_request(:get, %r{http://lib-solr8-prod.princeton.edu:8983/solr/pulfalight-production})
      .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
  end

  it 'returns json' do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulfalight-production/select?facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,abstract_ssm,repository_ssm,extent_ssm,accessrestrict_ssm,normalized_date_ssm&q=cats&rows=3&sort=score%20desc,%20title_sort%20asc&fq=level_ssm:collection')
      .to_return(status: 200, body: file_fixture('solr/findingaids/cats.json'))
    get '/search/findingaids?query=cats'

    expect(last_response).to be_successful
    expect(last_response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulfalight-production/select?facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,abstract_ssm,repository_ssm,extent_ssm,accessrestrict_ssm,normalized_date_ssm&q=cats&rows=3&sort=score%20desc,%20title_sort%20asc&fq=level_ssm:collection')
        .to_return(status: 200, body: file_fixture('solr/findingaids/cats.json'))
    end

    let(:expected_response) do
      { number: 325,
        more: 'https://findingaids.princeton.edu/catalog?q=cats&search_field=all_fields',
        records: [
          { title: 'Edward Anthony Papers, 1920s -1950s',
            creator: 'Anthony, Edward, 1895-1971',
            id: 'TC125',
            type: 'collection',
            description: 'Edward Anthony was a noted writer and publisher in the twentieth century, known primarily ' \
                         'for his light verse. His papers include several manuscripts, including an autobiography ' \
                         'co-authored with Clyde Beatty about circus animal training and a collection of poems. A ' \
                         'few miscellaneous papers, such as letters and a date book from 1928 complete the collection.',
            url: 'https://findingaids.princeton.edu/catalog/TC125',
            other_fields: {
              access_restriction: 'Collection is open for research use.',
              date: '1920s -1950s',
              extent: '2 boxes and 0.8 linear feet',
              repository: 'Manuscripts Division'
            } }
        ] }
    end

    it 'can take a parameter' do
      get '/search/findingaids?query=cats'

      expect(last_response).to be_successful
      response_body = JSON.parse(last_response.body, symbolize_names: true)

      expect(response_body.keys).to contain_exactly(:number, :more, :records)
      expect(response_body[:number]).to eq(expected_response[:number])
      expect(response_body[:records].first.keys).to contain_exactly(:title, :creator, :id, :type, :description, :url,
                                                                    :other_fields)
      expect(response_body[:records].first).to match(expected_response[:records].first)
    end

    it 'only returns the first three records' do
      get '/search/findingaids?query=cats'

      response_body = JSON.parse(last_response.body, symbolize_names: true)

      expect(response_body[:records].size).to eq(3)
    end
  end

  context 'without a search term' do
    it 'returns a 400 bad request' do
      get '/search/findingaids?query='

      expect(last_response.status).to eq 400
    end
  end

  it_behaves_like 'a solr search controller'
end
