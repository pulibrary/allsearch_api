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

      response(200, 'successful') do
        let(:query) { 'scribner' }
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
