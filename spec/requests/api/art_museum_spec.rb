# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'art_museum' do
  before do
    stub_art_museum(query: 'cats', fixture: 'art_museum/cats.json')
  end

  path '/search/artmuseum?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query the Art Museum'
    get('/search/artmuseum?query={query}') do
      tags 'Art Museum'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Art Museum using a query term'
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
