# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'catalog' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=rubix&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
      .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=some_search&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
      .to_return(status: 404, body: file_fixture('solr/catalog/404.html'))
    allow(Honeybadger).to receive(:notify)
  end

  openapi_path '/search/catalog' do
    openapi_parameter 'name' => 'query', 'in' => 'query', 'description' => 'A string to query the Catalog',
                      'schema' => { 'type' => 'string' }

    openapi_get({
                  'summary' => '/search/catalog?query={query}',
                  'tags' => ['Catalog'],
                  'operationId' => 'searchCatalog',
                  'description' => 'Searches the Catalog using a query term'
                }) do
      openapi_response('200', 'successful', { query: 'rubix' })

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

      openapi_response('500', 'with solr reporting 404', { query: 'some_search' }) do |url|
        it 'gives a reasonable error message' do
          get url
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'UPSTREAM_ERROR',
                                       message: 'Solr returned a 404 for path /solr/catalog-alma-production/select ' \
                                                'on host lib-solr8-prod.princeton.edu'
                                     })
          expect(Honeybadger).to have_received(:notify)
        end
      end
    end
  end
end
