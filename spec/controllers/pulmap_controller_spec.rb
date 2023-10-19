# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PulmapController do
  it 'sanitizes input' do
    stub_solr(collection: 'pulmap',
              query: 'facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,' \
                     'dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&' \
                     'q=bad%20bin%20bash%20script&rows=3&sort=score%20desc',
              fixture: 'solr/pulmap/scribner.json')
    get :show, params: { query: '{bad#!/bin/bash<script>}' }
    expect(controller.query.query_terms).to eq('bad bin bash script')
  end

  it 'removes redundant space from query' do
    stub_solr(collection: 'pulmap',
              query: 'facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,' \
                     'dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&' \
                     'q=war%20and%20peace&rows=3&sort=score%20desc',
              fixture: 'solr/pulmap/scribner.json')
    get :show, params: { query: "war   and\tpeace" }
    expect(controller.query.query_terms).to eq('war and peace')
  end
end
