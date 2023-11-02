# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'libguides' do
  path '/search/libguides?query={query}' do
    parameter name: 'query', in: :path, type: :string, description: 'A string to query Libguides'
    get('/search/libguides?query={query}') do
      tags 'Libguides'
      consumes 'application/json'
      produces 'application/json'
      description 'Searches the Libguides research guides using a query term'

      after do |example|
        example.metadata[:response][:content] = {
          'application/json' => {
            example: JSON.parse(response.body, symbolize_names: true)
          }
        }
      end

      describe 'with valid authentication' do
        before do
          stub_request(:post, 'https://lgapi-us.libapps.com/1.2/oauth/token')
            .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
            .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
          stub_request(:get, 'https://lgapi-us.libapps.com/1.2/guides?expand=owner,subjects,tags&search_terms=Asian%20American%20Studies&sort_by=relevance&status=1')
            .with(
              headers: {
                'Authorization' => 'Bearer abcdef1234567890abcdef1234567890abcdef12'
              }
            )
            .to_return(status: 200, body: file_fixture('libguides/asian_american_studies.json'))
        end

        response(200, 'successful') do
          let(:query) { 'Asian American Studies' }
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

      response(500, "when the system can't authenticate with libguides") do
        let(:query) { 'some_query' }
        before do
          stub_request(:post, 'https://lgapi-us.libapps.com/1.2/oauth/token')
            .to_return(status: 400, body: '{"error":"The client credentials are invalid"}')
        end

        run_test! do |response|
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'UPSTREAM_ERROR',
                                       message: 'Could not generate a valid authentication token with upstream service.'
                                     })
        end
      end
    end
  end
end
