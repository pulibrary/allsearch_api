# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'findingaids' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulfalight-production/select?facet=false&fl=id,collection_ssm,creator_ssm,level_sim,scopecontent_ssm,repository_ssm,extent_ssm,accessrestrict_ssm&q=cats&rows=3&sort=score%20desc,%20title_sort%20asc&fq=level_sim:Collection')
      .to_return(status: 200, body: file_fixture('solr/findingaids/cats.json'))
  end

  path '/search/findingaids?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query Findingaids'

    get('/search/findingaids?query={query}') do
      tags 'Findingaids'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches Findingaids using a query term'

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
