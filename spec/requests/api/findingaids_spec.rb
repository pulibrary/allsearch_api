# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'findingaids' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulfalight-production/select?facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,abstract_ssm,repository_ssm,extent_ssm,accessrestrict_ssm,normalized_date_ssm&q=cats&rows=3&sort=score%20desc,%20title_sort%20asc&fq=level_ssm:collection')
      .to_return(status: 200, body: file_fixture('solr/findingaids/cats.json'))
  end

  openapi_path '/search/findingaids' do
    openapi_parameter 'name' => 'query', 'in' => 'query', 'description' => 'A string to query Findingaids',
                      'schema' => { 'type' => 'string' }

    openapi_get({
                  'summary' => '/search/findingaids?query={query}',
                  'tags' => ['Findingaids'],
                  'operationId' => 'searchFindingaids',
                  'description' => 'Searches Findingaids using a query term'

                }) do
      openapi_response('200', 'successful', { query: 'cats' })

      openapi_response('400', 'with an empty search query', { query: '' }) do |url|
        it 'gives the empty query message' do
          get url
          data = JSON.parse(last_response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end

      openapi_response('400', 'with a search query that only contains whitespace', { query: "\t  \n " }) do |url|
        it 'gives the empty query message' do
          get url
          data = JSON.parse(last_response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end
    end
  end
end
