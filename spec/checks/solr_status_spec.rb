# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrStatus do
  let(:solr_status) { described_class.new }

  context 'with a successful request to solr' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/admin/cores?action=STATUS').to_return(
        body: { responseHeader: { status: 0 } }.to_json, headers: { 'Content-Type' => 'text/json' }
      )
    end

    it 'returns nil on the check! method' do
      expect(solr_status.check!).to be_nil
    end
  end

  context 'with an unsuccessful request to solr' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/admin/cores?action=STATUS').to_return(
        body: { responseHeader: { status: 500 } }.to_json, headers: { 'Content-Type' => 'text/json' }
      )
    end

    it 'raises an error' do
      expect { solr_status.check! }.to raise_error(RuntimeError, /The solr has an invalid status/)
    end
  end
end
