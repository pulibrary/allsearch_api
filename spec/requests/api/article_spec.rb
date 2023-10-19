# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'article' do
  before do
    stub_summon(query: 'potato', fixture: 'article/potato.json')
  end

  path '/search/article?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query the Summon API, aka Articles+'
    get('/search/article?query={query}') do
      tags 'Article'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Summon API using a query term. Excludes Newspaper Articles and items not held by PUL'

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end

      response(200, 'successful') do
        let(:query) { 'potato' }
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
