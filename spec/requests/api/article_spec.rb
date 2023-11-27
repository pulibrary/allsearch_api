# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'article' do
  before do
    stub_summon(query: 'potato', fixture: 'article/potato.json')
    stub_request(:get,
                 'http://api.summon.serialssolutions.com/2.0.0/search?s.dym=t&s.fvf=ContentType,Newspaper%20Article,true&s.ho=t&s.ps=3&s.q=some_search')
      .to_return(status: 401)
  end

  path '/search/article' do
    parameter name: 'query', in: :query, type: :string, description: 'A string to query the Summon API, aka Articles+'
    get('/search/article?query={query}') do
      tags 'Article'
      operationId 'searchArticle'
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

      response(500, "when we can't authenticate to the summon API") do
        let(:query) { 'some_search' }

        run_test! do |response|
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'UPSTREAM_ERROR',
                                       message: 'Could not authenticate to the upstream Summon service'
                                     })
        end
      end
    end
  end
end
