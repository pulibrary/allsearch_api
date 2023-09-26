# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DpulController do
  it 'sanitizes input' do
    stub_solr(collection: 'dpul-production',
              query: 'facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,' \
                     'readonly_format_ssim,readonly_collections_tesim&' \
                     'q=bad%20bin%20bash%20script&rows=3&sort=score%20desc',
              fixture: 'solr/dpul/cats.json')
    get :show, params: { query: '{bad#!/bin/bash<script>}' }
    expect(controller.query.query_terms).to eq('bad bin bash script')
  end

  it 'removes redundant space from query' do
    stub_solr(collection: 'dpul-production',
              query: 'facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,' \
                     'readonly_format_ssim,readonly_collections_tesim&' \
                     'q=war+and+peace&rows=3&sort=score%20desc',
              fixture: 'solr/dpul/cats.json')
    get :show, params: { query: "war   and\tpeace" }
    expect(controller.query.query_terms).to eq('war and peace')
  end
end
