# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe CatalogController do
  before do
    stub_solr(collection: 'catalog-alma-production',
              query: 'facet=false&fl=id,title_display,author_display,pub_created_display,format,' \
                     'holdings_1display,electronic_portfolio_s,electronic_access_1display&' \
                     'q=bad+bin+bash+script&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc',
              fixture: 'solr/catalog/rubix.json')
    stub_solr(collection: 'catalog-alma-production',
              query: 'facet=false&fl=id,title_display,author_display,pub_created_display,format,' \
                     'holdings_1display,electronic_portfolio_s,electronic_access_1display&' \
                     'q=war+and+peace&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc',
              fixture: 'solr/catalog/rubix.json')
    stub_solr(collection: 'catalog-alma-production',
              query: 'facet=false&fl=id,title_display,author_display,pub_created_display,format,' \
                     'holdings_1display,electronic_portfolio_s,electronic_access_1display&' \
                     'q=读&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc',
              fixture: 'solr/catalog/rubix.json')
    stub_solr(collection: 'catalog-alma-production',
              query: 'facet=false&fl=id,title_display,author_display,pub_created_display,format,' \
                     'holdings_1display,electronic_portfolio_s,electronic_access_1display&' \
                     'q=%25&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc',
              fixture: 'solr/catalog/no_results.json')
  end

  it_behaves_like 'a service controller'

  context 'when service returns a Net::HTTP exception' do
    before do
      allow(Catalog).to receive(:new).and_raise(Net::HTTPFatalError.new('Some info', ''))
      allow(Honeybadger).to receive(:notify)
    end

    it 'handles Net::HTTP exceptions' do
      get :show, params: { query: '123' }
      expect(response).to have_http_status(:internal_server_error)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq({
                                   problem: 'UPSTREAM_ERROR',
                                   message: 'Query to upstream failed with Net::HTTPFatalError, message: Some info'
                                 })
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
