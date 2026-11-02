# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Catalog do
  describe '#more_link' do
    before do
      stub_solr(collection: 'catalog-alma-production',
                query: 'facet=false&fl=id,title_display,author_display,pub_created_display,format,' \
                       'holdings_1display,electronic_portfolio_s,electronic_access_1display&' \
                       'q=rubix&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc',
                fixture: 'solr/catalog/rubix.json')
    end

    it 'links to the host associated with the solr collection' do
      catalog = described_class.new
      our_response = catalog.our_response(query_terms: 'rubix')
      expect(JSON.parse(our_response)['more']).to eq('https://catalog.princeton.edu/catalog?q=rubix&search_field=all_fields')
    end

    context 'when on a non-production environment' do
      before do
        stub_request(:get, 'http://lib-solr8d-staging.princeton.edu:8983/solr/catalog-staging/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=rubix&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
          .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
      end

      it 'links to the host associated with the solr collection' do
        catalog = described_class.new(
          allsearch_config: Environment.new({ 'APP_ENV' => 'staging' }).config(:allsearch)
        )
        our_response = catalog.our_response(query_terms: 'rubix')
        expect(JSON.parse(our_response)['more']).to eq('https://catalog-staging.princeton.edu/catalog?q=rubix&search_field=all_fields')
      end
    end
  end

  describe '#our_response' do
    it 'logs an error if we timeout communicating with solr' do
      stub_request(:any, /solr/).to_timeout
      stub_const('ALLSEARCH_LOGGER', instance_double(SemanticLogger::Logger, error: true))

      expect do
        described_class.new.our_response(query_terms: 'rubix')
      end.to raise_error AllsearchError

      expect(ALLSEARCH_LOGGER).to have_received(:error).with('Solr error', Net::OpenTimeout)
    end

    it 'logs an error if the connection to solr is reset mid-response' do
      stub_request(:any, /solr/).to_raise(Net::ProtoFatalError.new('end of file reached'))
      stub_const('ALLSEARCH_LOGGER', instance_double(SemanticLogger::Logger, error: true))

      expect do
        described_class.new.our_response(query_terms: 'rubix')
      end.to raise_error AllsearchError

      expect(ALLSEARCH_LOGGER).to have_received(:error).with('Solr error', an_instance_of(Net::ProtoFatalError))
    end
  end
end
