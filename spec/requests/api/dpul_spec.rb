# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'dpul' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/dpul-production/select?facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,readonly_format_ssim,readonly_collections_tesim&q=cats&rows=3&sort=score%20desc')
      .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
  end

  path '/search/dpul?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query Dpul'

    get('/search/dpul?query={query}') do
      tags 'Dpul'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches Dpul using a query term'

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end

      response(200, 'successful') do
        let(:query) { 'cats' }
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
    end
  end
end
