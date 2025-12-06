# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolrCheck do
  it 'returns success when the solr collection is healthy' do
    stub_request(:get, 'http://my-solr:8983/solr/my-collection/admin/ping').to_return(status: 200,
                                                                                      body: { status: 'OK' }.to_json)
    result = described_class.new(host: 'my-solr', collection: 'my-collection').call
    expect(result).to be_success
  end

  it 'returns failure when the solr collection is not found' do
    stub_request(:get, 'http://my-solr:8983/solr/my-collection/admin/ping').to_return(status: 404, body: '')
    result = described_class.new(host: 'my-solr', collection: 'my-collection').call
    expect(result).to be_failure
    expect(result.failure).to eq 'The Solr collection has an invalid status http://my-solr:8983/solr/my-collection/admin/ping'
  end

  it 'returns failure when there is an error requesting the solr ping' do
    stub_request(:get, 'http://my-solr:8983/solr/my-collection/admin/ping')
      .to_raise(StandardError.new('there was a BIG problem'))
    result = described_class.new(host: 'my-solr', collection: 'my-collection').call
    expect(result).to be_failure
    expect(result.failure).to eq 'there was a BIG problem'
  end
end
