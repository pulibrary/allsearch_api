# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'art_museum' do
  before do
    stub_art_museum(query: 'cats', fixture: 'art_museum/cats.json')
  end

  openapi_path '/search/artmuseum' do
    openapi_parameter 'name' => 'query', 'in' => 'query',
                      'description' => 'A string to query the Art Museum',
                      'schema' => { 'type' => 'string' }
    openapi_get({
                  'summary' => '/search/artmuseum?query={query}',
                  'tags' => ['Art Museum'],
                  'operationId' => 'searchArtmuseum',
                  'description' => 'Searches the Art Museum using a query term'
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
