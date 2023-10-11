# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogController do
  it 'sanitizes input' do
    stub_solr(collection: 'catalog-alma-production',
              query: 'facet=false&fl=id,title_display,author_display,pub_created_display,format,' \
                     'holdings_1display,electronic_portfolio_s,electronic_access_1display&' \
                     'q=bad+bin+bash+script&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc',
              fixture: 'solr/catalog/rubix.json')
    get :show, params: { query: '{bad#!/bin/bash<script>}' }
    expect(controller.query.query_terms).to eq('bad bin bash script')
  end

  it 'removes redundant space from query' do
    stub_solr(collection: 'catalog-alma-production',
              query: 'facet=false&fl=id,title_display,author_display,pub_created_display,format,' \
                     'holdings_1display,electronic_portfolio_s,electronic_access_1display&' \
                     'q=war+and+peace&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc',
              fixture: 'solr/catalog/rubix.json')
    get :show, params: { query: "war   and\tpeace" }
    expect(controller.query.query_terms).to eq('war and peace')
  end
end
