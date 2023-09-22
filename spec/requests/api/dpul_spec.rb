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

      response(200, 'successful') do
        let(:query) { 'cats' }
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
