# frozen_string_literal: true

require 'swagger_helper'
require 'rails_helper'

RSpec.describe 'website' do
  before do
    stub_website(query: 'firestone', fixture: 'library_website/firestone.json')

    url = 'https://library.psb-prod.princeton.edu/ps-library/search/results'
    stub_request(:post, url)
      .with(body: { 'search' => '' })
      .to_return(status: 401)
  end

  path '/search/website?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query the Library Website'
    get('/search/article?query={query}') do
      tags 'Library Website'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Library Website using a query term.'

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end

      response(200, 'successful') do
        let(:query) { 'firestone' }
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
