# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'library_database' do
  path '/search/database?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query the Library Databases'

    get('search/database?query={query}') do
      tags 'Library Databases'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches for relevant Library Databases using a query term'

      response(200, 'successful') do
        let(:query) { 'oxford music' }

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
