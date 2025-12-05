# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'libanswers' do
  describe 'with valid authentication' do
    before do
      stub_libanswers(query: 'printer', fixture: 'libanswers/printer.json')
    end

    openapi_path '/search/libanswers' do
      openapi_parameter 'name' => 'query', 'in' => 'query', 'description' => 'A string to query Libanswers',
                        'schema' => { 'type' => 'string' }
      openapi_get({
                    'summary' => '/search/libanswers?query={query}',
                    'tags' => ['Libanswers'],
                    'operationId' => 'searchLibanswers',
                    'description' => 'Searches the Libanswers FAQs using a query term'
                  }) do
        openapi_response('200', 'successful', { query: 'printer' })

        openapi_response('400', 'with a search query that only contains whitespace',
                         { query: "\t  \n " }) do |url|
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
    describe "when the system can't authenticate with libanswers" do
      before do
        stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token')
          .to_return(status: 400, body: '{"error":"The client credentials are invalid"}')
        allow(Honeybadger).to receive(:notify)
      end

      openapi_path '/search/libanswers' do
        openapi_get({
                      'summary' => '/search/libanswers?query={query}',
                      'tags' => ['Libanswers'],
                      'operationId' => 'searchLibanswers',
                      'description' => 'Searches the Libanswers FAQs using a query term'
                    }) do
          openapi_response('500', "when the system can't authenticate with libanswers",
                           { query: 'some query' }) do |url|
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
end
