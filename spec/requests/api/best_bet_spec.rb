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
