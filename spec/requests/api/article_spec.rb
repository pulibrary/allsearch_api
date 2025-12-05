# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'article' do
  before do
    stub_summon(query: 'potato', fixture: 'article/potato.json')
    stub_request(:get,
                 'http://api.summon.serialssolutions.com/2.0.0/search?s.dym=t&s.fvf=ContentType,Newspaper%20Article,true&s.ho=t&s.ps=3&s.q=some_search')
      .to_return(status: 401)
    allow(Honeybadger).to receive(:notify)
  end

  openapi_path '/search/article' do
    openapi_parameter({
                        'name' => 'query',
                        'in' => 'query',
                        'description' => 'A string to query the Summon API, aka Articles+',
                        'schema' => { 'type' => 'string' }
                      })
    openapi_get({
                  'summary' => '/search/article?query={query}',
                  'tags' => ['Article'],
                  'operationId' => 'searchArticle',
                  'description' =>
                    'Searches the Summon API using a query term. Excludes Newspaper Articles and items not held by PUL'
                }) do
      openapi_response('200', 'successful', { query: 'potato' })

      openapi_response('400', 'with an empty search query', { query: '' }) do |url|
        it 'gives the empty query message' do
          get url
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'QUERY_IS_EMPTY',
                                       message: 'The query param must contain non-whitespace characters.'
                                     })
        end
      end

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

      openapi_response('500', "when we can't authenticate to the summon API", { query: 'some_search' }) do |url|
        it 'gives a reasonable error message' do
          get url
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:error]).to eq({
                                       problem: 'UPSTREAM_ERROR',
                                       message: 'Could not authenticate to the upstream Summon service'
                                     })
          expect(Honeybadger).to have_received(:notify)
        end
      end
    end
  end
end
