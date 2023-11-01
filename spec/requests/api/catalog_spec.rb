# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'catalog' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=rubix&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
      .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=some_search&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
      .to_return(status: 404, body: file_fixture('solr/catalog/404.html'))
  end

  path '/search/catalog?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query the Catalog'

    get('/search/catalog?query={query}') do
      tags 'Catalog'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Catalog using a query term'

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end

      response(200, 'successful') do
        let(:query) { 'rubix' }
        run_test!
      end

      response(400, 'with an empty search query') do
        let(:query) { '' }
        run_test! do |response|
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end

      response(400, 'with a search query that only contains whitespace') do
        let(:query) { "\t  \n " }
        run_test! do |response|
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end

      response(500, 'with solr reporting 404') do
        let(:query) { 'some_search' }

        run_test! do |response|
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'UPSTREAM_ERROR',
                                       message: 'Solr returned a 404 for path /solr/catalog-alma-production/select ' \
                                                'on host lib-solr8-prod.princeton.edu'
                                     })
        end
      end
    end
  end
end
