# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'findingaids' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulfalight-production/select?facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,scopecontent_ssm,repository_ssm,extent_ssm,accessrestrict_ssm,normalized_date_ssm&q=cats&rows=3&sort=score%20desc,%20title_sort%20asc&fq=level_ssm:collection')
      .to_return(status: 200, body: file_fixture('solr/findingaids/cats.json'))
  end

  path '/search/findingaids?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query Findingaids'

    get('/search/findingaids?query={query}') do
      tags 'Findingaids'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches Findingaids using a query term'

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
