# frozen_string_literal: true

require 'rails_helper'

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
      catalog = described_class.new(query_terms: 'rubix')
      expect(catalog.more_link.value!.to_s).to eq('https://catalog.princeton.edu/catalog?q=rubix&search_field=all_fields')
    end

    context 'when on a non-production environment' do
      before do
        stub_request(:get, 'http://lib-solr8d-staging.princeton.edu:8983/solr/catalog-staging/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=rubix&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
          .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
      end

      it 'links to the host associated with the solr collection' do
        catalog = described_class.new(
          query_terms: 'rubix',
          allsearch_config: Environment.new({ 'RAILS_ENV' => 'staging' }).config(:allsearch)
        )
        expect(catalog.more_link.value!.to_s).to eq('https://catalog-staging.princeton.edu/catalog?q=rubix&search_field=all_fields')
      end
    end
  end
end
