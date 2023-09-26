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
