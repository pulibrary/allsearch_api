# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health Check' do
  describe 'GET /health' do
    it 'has a health check' do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/admin/cores?action=STATUS').to_return(
        body: { responseHeader: { status: 0 } }.to_json, headers: { 'Content-Type' => 'text/json' }
      )

      get '/health.json'
      expect(response).to be_successful
    end

    it 'errors when a service is down' do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/admin/cores?action=STATUS').to_return(
        body: { responseHeader: { status: 500 } }.to_json, headers: { 'Content-Type' => 'text/json' }
      )

      get '/health.json'

      expect(response).not_to be_successful
      expect(response).to have_http_status :service_unavailable
      solr_response = response.parsed_body['results'].find { |x| x['name'] == 'SolrStatus' }
      expect(solr_response['message']).to start_with 'The solr has an invalid status'
    end
  end
end
