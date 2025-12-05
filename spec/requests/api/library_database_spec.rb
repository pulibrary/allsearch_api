# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'library_database' do
  openapi_path '/search/database' do
    openapi_parameter 'name' => 'query', 'in' => 'query', 'description' => 'A string to query the Library Databases',
                      'schema' => { 'type' => 'string' }

    openapi_get({
                  'summary' => '/search/database?query={query}',
                  'tags' => ['Library Databases'],
                  'operationId' => 'searchDatabase',
                  'description' => 'Searches for relevant Library Databases using a query term'
                }) do
      openapi_response('200', 'successful', { query: 'oxford music' })

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
