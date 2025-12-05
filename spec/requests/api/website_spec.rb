# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'website' do
  let(:url) do
    URI::HTTPS.build(host: LibraryWebsite.library_website_host, path: '/ps-library/search/results')
  end

  before do
    stub_website(query: 'firestone', fixture: 'library_website/firestone.json')
    stub_request(:post, url)
      .with(body: { 'search' => '' })
      .to_return(status: 401)
  end

  openapi_path '/search/website' do
    openapi_parameter 'name' => 'query', 'in' => 'query', 'description' => 'A string to query the Library Website',
                      'schema' => { 'type' => 'string' }
    openapi_get({
                  'summary' => '/search/website?query={query}',
                  'tags' => ['Library Website'],
                  'operationId' => 'searchWebsite',
                  'description' => 'Searches the Library Website using a query term.'
                }) do
      openapi_response('200', 'successful', { query: 'firestone' })

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
