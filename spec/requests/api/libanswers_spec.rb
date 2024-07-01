# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'libanswers' do
  path '/search/libanswers' do
    parameter name: 'query', in: :query, type: :string, description: 'A string to query Libanswers'
    get('/search/libanswers?query={query}') do
      tags 'Libanswers'
      operationId 'searchLibanswers'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Libanswers FAQs using a query term'

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end

      describe 'with valid authentication' do
        before do
          stub_libanswers(query: 'printer', fixture: 'libanswers/printer.json')
        end

        response(200, 'successful') do
          let(:query) { 'printer' }
          run_test!
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

      response(500, "when the system can't authenticate with libanswers") do
        let(:query) { 'some_query' }
        before do
          stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token')
            .to_return(status: 400, body: '{"error":"The client credentials are invalid"}')
          allow(Honeybadger).to receive(:notify)
        end

        run_test! do |response|
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'UPSTREAM_ERROR',
                                       message: 'Could not generate a valid authentication token with upstream service.'
                                     })
          expect(Honeybadger).to have_received(:notify)
        end
      end
    end
  end
end
