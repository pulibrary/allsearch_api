# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'dpul' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/dpul-production/select?facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,readonly_format_ssim,readonly_collections_tesim&group=true&group.facet=true&group.field=content_metadata_iiif_manifest_field_ssi&group.limit=1&group.main=true&q=cats&rows=3&sort=score%20desc')
      .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
  end

  openapi_path '/search/dpul' do
    openapi_parameter 'name' => 'query', 'in' => 'query', 'description' => 'A string to query Dpul',
                      'schema' => { 'type' => 'string' }

    openapi_get({
                  'summary' => '/search/dpul?query={query}',
                  'tags' => ['Dpul'],
                  'operationId' => 'searchDpul',
                  'description' => 'Searches Dpul using a query term'
                }) do
      openapi_response('200', 'successful', { query: 'cats' })

      openapi_response('400', 'with an empty search query', { query: '' }) do |url|
        it 'gives the empty query message' do
          get url
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end

      openapi_response('400', 'with a search query that only contains whitespace', { query: "\t  \n " }) do |url|
        it 'gives the empty query message' do
          get url
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end
    end
  end
end
