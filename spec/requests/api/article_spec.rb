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

      response(200, 'successful') do
        let(:query) { 'potato' }
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
