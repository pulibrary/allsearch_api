# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'best_bet' do
  path '/search/best-bet?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query the Best Bets'
    get('/search/best-bet?query={query}') do
      tags 'Best Bets'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Best Bets using a query term'

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
