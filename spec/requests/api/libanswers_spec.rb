# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'libanswers' do
  before do
    stub_libanswers(query: 'printer', fixture: 'libanswers/printer.json')
  end

  path '/search/libanswers?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query Libanswers'
    get('/search/libanswers?query={query}') do
      tags 'Libanswers'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Libanswers FAQs using a query term'

      response(200, 'successful') do
        let(:query) { 'printer' }
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
