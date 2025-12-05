# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'libguides' do
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

    openapi_path '/search/libguides' do
      openapi_parameter 'name' => 'query', 'in' => 'query', 'description' => 'A string to query Libguides',
                        'schema' => { 'type' => 'string' }
      openapi_get({
                    'summary' => '/search/libguides?query={query}',
                    'tags' => ['Libguides'],
                    'operationId' => 'searchLibguides',
                    'description' => 'Searches the Libguides research guides using a query term'
                  }) do
        openapi_response('200', 'successful', { query: 'Asian American Studies' })

        openapi_response('400', 'with a search query that only contains whitespace', { query: "\t  \n " }) do |url|
          it 'gives the empty query message' do
            get url
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

  describe "when the system can't authenticate with libguides" do
    before do
      stub_request(:post, 'https://lgapi-us.libapps.com/1.2/oauth/token')
        .to_return(status: 400, body: '{"error":"The client credentials are invalid"}')
      allow(Honeybadger).to receive(:notify)
    end

    openapi_path '/search/libguides' do
      openapi_get({
                    'summary' => '/search/libguides?query={query}',
                    'tags' => ['Libguides'],
                    'operationId' => 'searchLibguides',
                    'description' => 'Searches the Libguides research guides using a query term'
                  }) do
        openapi_response('500', "when the system can't authenticate with libguides", { query: 'some_query' }) do |url|
          it 'gives a relevant error message' do
            get url
            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:error])
              .to eq({
                       problem: 'UPSTREAM_ERROR',
                       message: 'Could not generate a valid authentication token with upstream service.'
                     })
            expect(Honeybadger).to have_received(:notify)
          end
        end
      end
    end
  end
end
