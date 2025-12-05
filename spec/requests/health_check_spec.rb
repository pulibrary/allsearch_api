# frozen_string_literal: true

require 'rails_helper'

def stub_solr_ping(headers: {}, status: 200, **)
  stub_request(:get, %r{http://lib-solr8-prod.princeton.edu:8983/solr/.*/admin/ping}).to_return(headers:, status:,
                                                                                                **)
end

RSpec.describe 'Health Check' do
  describe 'GET /health' do
    it 'has a table of results' do
      stub_solr_ping(body: { status: 'OK' }.to_json, headers: { 'Content-Type' => 'text/json' })

      get '/health'
      expect(last_response).to be_successful
      expect(Nokogiri.HTML(last_response.body).css('table')).not_to be_empty
    end

    it 'returns JSON if Content-Type is application/json' do
      stub_solr_ping(body: { status: 'OK' }.to_json, headers: { 'Content-Type' => 'text/json' })

      header 'Accept', 'application/json'
      get '/health'
      expect(last_response).to be_successful
      expect { JSON.parse(last_response.body) }.not_to raise_error
    end
  end

  describe 'GET /health.json' do
    it 'responds with valid JSON' do
      stub_solr_ping(body: { status: 'OK' }.to_json, headers: { 'Content-Type' => 'text/json' })

      get '/health.json'
      expect(last_response).to be_successful
      expect { JSON.parse(last_response.body) }.not_to raise_error
    end

    it 'does not error when a service is down' do
      stub_solr_ping(status: 404, body: '')

      get '/health.json'

      expect(last_response).to be_successful
      solr_response = JSON.parse(last_response.body)['results'].find { |x| x['name'] == 'Solr: catalog' }
      expect(solr_response['message']).to start_with 'The Solr collection has an invalid status'
    end

    it 'returns on overall error when the remove-from-nginx file is present' do
      stub_solr_ping(body: { status: 'OK' }.to_json)
      remove_from_nginx_path = allsearch_path('public/remove-from-nginx')
      File.open remove_from_nginx_path, 'w'

      get '/health.json'

      expect(JSON.parse(last_response.body)['status']).to eq 'error'

      File.delete remove_from_nginx_path
    end
  end
end
