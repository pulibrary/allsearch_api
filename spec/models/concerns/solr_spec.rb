# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Solr do
  let(:allsearch_config) do
    {
      service: { solr: { host: 'lib-solr9-prod.princeton.edu', port: 8983, collection: 'dpul-production' } }
    }
  end

  let(:consumer_class) do
    Class.new do
      include Solr

      def initialize(query_terms:, allsearch_config:)
        @query_terms = query_terms
        @allsearch_config = allsearch_config
        @service = 'service'
        @service_response = solr_service_response
      end

      def solr_fields = %w[id]
      def solr_sort = 'score desc'
      attr_reader :service, :query_terms, :allsearch_config
    end
  end

  def solr_request
    consumer_class.new(query_terms: 'The Sense of an Ending', allsearch_config:)
  end

  context 'when Solr returns a 500' do
    before do
      stub_request(:get, %r{solr/dpul-production/select})
        .to_return(status: 500,
                   body: %({"response": {"numFound": 0, "docs": []}, "error": {"msg": "oops"}}))
    end

    it 'includes the response body in the AllsearchError message' do
      expect do
        solr_request
      end.to raise_error AllsearchError, /response body: .*"msg": "oops"/
    end

    it 'does not blow up when the body is nil' do
      stub_request(:get, %r{solr/dpul-production/select}).to_return(status: 500, body: nil,
                                                                    headers: { 'Content-Type': 'text/plain' })

      expect do
        solr_request
      end.to raise_error AllsearchError, /response body:/
    end

    it 'caps long response bodies in the message' do
      long_body = 'A' * 50_000
      stub_request(:get, %r{solr/dpul-production/select}).to_return(status: 500, body: long_body)

      error = nil
      expect { solr_request }.to raise_error(AllsearchError) { |e| error = e }

      expect(error.message.length).to be < 12_000
    end
  end
end
