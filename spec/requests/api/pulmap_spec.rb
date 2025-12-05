# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'pulmap' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulmap/select?facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&q=scribner&rows=3&sort=score%20desc')
      .to_return(status: 200, body: file_fixture('solr/pulmap/scribner.json'))
  end

  openapi_path '/search/pulmap' do
    openapi_parameter 'name' => 'query', 'in' => 'query', 'description' => 'A string to query Pulmap',
                      'schema' => { 'type' => 'string' }

    openapi_get({
                  'summary' => '/search/pulmap?query={query}',
                  'tags' => ['Pulmap'],
                  'operationId' => 'searchPulmap',
                  'description' => 'Searches Pulmap using a query term'
                }) do
      openapi_response('200', 'successful', { query: 'scribner' })

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
