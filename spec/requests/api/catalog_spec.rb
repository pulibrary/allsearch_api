# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'catalog' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display&q=rubix&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
      .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
  end

  path '/search/catalog?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query the Catalog'

    get('/search/catalog?query={query}') do
      tags 'Catalog'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Catalog using a query term'

      response(200, 'successful') do
        let(:query) { 'rubix' }
        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end
    end
  end
end
