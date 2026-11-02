# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolrClient do
  let(:solr_config) { { host: 'lib-solr9-prod.princeton.edu', port: 8983, collection: 'dpul-production' } }
  let(:query_builder) { ->(query) { "q=#{query}&rows=3&facet=false&fl=id&sort=score%20desc" } }

  describe '#query' do
    it 'returns the solr json response' do
      stub_request(:get, %r{/solr/dpul-production/select})
        .to_return(status: 200, body: '{"response":{"numFound":1,"docs":[]}}')

      expect(described_class.new(solr_config:, query_builder:).query(query_terms: 'sense')).to eq(
        response: { numFound: 1, docs: [] }
      )
    end

    context 'when the client is reused' do
      it 'can respond to mulitple queries' do
        stub_request(:get, %r{/solr/dpul-production/select}).to_return(
          [{ status: 200, body: '{"response":{"numFound":1,"docs":[]}}' },
           { status: 200, body: '{"response":{"numFound":2,"docs":[]}}' }]
        )
        client = described_class.new(solr_config:, query_builder:)

        expect(client.query(query_terms: 'one')).to eq(response: { numFound: 1, docs: [] })
        expect(client.query(query_terms: 'two')).to eq(response: { numFound: 2, docs: [] })
      end

      it 'reuses the connection for every query' do
        response = Struct.new(:code, :body).new('200', '{"response":{"numFound":1,"docs":[]}}')
        connection = instance_double(Net::HTTP, get: response)
        client = described_class.new(solr_config:, connection:, query_builder:)

        client.query(query_terms: 'one')
        client.query(query_terms: 'two')

        expect(connection).to have_received(:get).exactly(2).times
      end
    end

    context 'when Solr returns a 500' do
      let(:body) { %({"response": {"numFound": 0, "docs": []}, "error": {"msg": "oops"}}) }

      before { stub_request(:get, %r{/solr/dpul-production/select}).to_return(status: 500, body:) }

      it 'raises an AllsearchError including the response body' do
        expect do
          described_class.new(solr_config:, query_builder:).query(query_terms: 'sense')
        end.to raise_error AllsearchError, /response body: .*"msg": "oops"/
      end

      it 'does not blow up when the body is nil' do
        stub_request(:get, %r{/solr/dpul-production/select}).to_return(status: 500, body: nil,
                                                                       headers: { 'Content-Type' => 'text/plain' })

        expect do
          described_class.new(solr_config:, query_builder:).query(query_terms: 'sense')
        end.to raise_error AllsearchError, /response body:/
      end

      it 'truncates long response bodies in the message' do
        stub_request(:get, %r{/solr/dpul-production/select}).to_return(status: 500, body: 'A' * 50_000)

        error = nil
        expect do
          described_class.new(solr_config:, query_builder:).query(query_terms: 'sense')
        end.to raise_error(AllsearchError) { |exception| error = exception.message }

        expect(error.length).to be < 12_000
      end
    end

    context 'when a request times out' do
      let(:logger) { instance_double(SemanticLogger::Logger, error: true) }

      it 'logs the transport error and raises' do
        stub = stub_request(:get, %r{/solr/dpul-production/select})
        stub.to_timeout
        client = described_class.new(solr_config:, logger:, query_builder:)

        expect do
          client.query(query_terms: 'sense')
        end.to raise_error AllsearchError
        expect(logger).to have_received(:error).with('Solr error', an_instance_of(Net::OpenTimeout))
      end
    end
  end
end
