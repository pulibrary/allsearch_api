# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrStatus do
  let(:solr_status) { described_class.new }
  let(:stub_success) do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/admin/cores?action=STATUS').to_return(
      body: { responseHeader: { status: 0 } }.to_json, headers: { 'Content-Type' => 'text/json' }
    )
  end
  let(:stub_failure) do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/admin/cores?action=STATUS').to_return(
      body: { responseHeader: { status: 500 } }.to_json, headers: { 'Content-Type' => 'text/json' }
    )
  end

  context 'with a successful request to solr' do
    before do
      stub_success
    end

    it 'returns nil on the check! method' do
      expect(solr_status.check!).to be_nil
      assert_requested(stub_success)
    end
  end

  context 'with an unsuccessful request to solr' do
    before do
      stub_failure
    end

    it 'raises an error' do
      expect { solr_status.check! }.to raise_error(RuntimeError, /The solr has an invalid status/)
      assert_requested(stub_failure)
    end
  end

  context 'with multiple solr hosts' do
    let(:stub_solr_9_success) do
      stub_request(:get, 'http://lib-solr9-prod.princeton.edu:8983/solr/admin/cores?action=STATUS').to_return(
        body: { responseHeader: { status: 0 } }.to_json, headers: { 'Content-Type' => 'text/json' }
      )
    end

    before do
      stub_success
      stub_solr_9_success
    end

    it 'checks more than one solr host' do
      solr_status.check!
      assert_requested(stub_success)
      # assert_requested(stub_solr_9_success)
    end
  end
end
