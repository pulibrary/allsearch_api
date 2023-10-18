# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'pulmap' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulmap/select?facet=false&fl=uuid,dc_title_s,dc_creator_sm,dc_publisher_s,dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&q=scribner&rows=3&sort=score%20desc')
      .to_return(status: 200, body: file_fixture('solr/pulmap/scribner.json'))
  end

  path '/search/pulmap?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query Pulmap'

    get('/search/pulmap?query={query}') do
      tags 'Pulmap'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches Pulmap using a query term'

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end

      response(200, 'successful') do
        let(:query) { 'scribner' }
        run_test!
      end

      response(400, 'with an empty search query') do
        let(:query) { '' }
        run_test! do |response|
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       code: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end

      response(400, 'with a search query that only contains whitespace') do
        let(:query) { "\t  \n " }
        run_test! do |response|
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       code: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end
    end
  end
end
