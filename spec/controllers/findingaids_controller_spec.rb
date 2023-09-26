# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FindingaidsController do
  it 'sanitizes input' do
    stub_solr(collection: 'pulfalight-production',
              query: 'facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,scopecontent_ssm,' \
                     'repository_ssm,extent_ssm,accessrestrict_ssm&fq=level_ssm:collection&' \
                     'q=bad%20bin%20bash%20script&rows=3&sort=score%20desc,%20title_sort%20asc',
              fixture: 'solr/findingaids/cats.json')
    get :show, params: { query: '{bad#!/bin/bash<script>}' }
    expect(controller.query.query_terms).to eq('bad bin bash script')
  end

  it 'removes redundant space from query' do
    stub_solr(collection: 'pulfalight-production',
              query: 'facet=false&fl=id,collection_ssm,creator_ssm,level_ssm,scopecontent_ssm,' \
                     'repository_ssm,extent_ssm,accessrestrict_ssm&fq=level_ssm:collection&' \
                     'q=war%20and%20peace&rows=3&sort=score%20desc,%20title_sort%20asc',
              fixture: 'solr/findingaids/cats.json')
    get :show, params: { query: "war   and\tpeace" }
    expect(controller.query.query_terms).to eq('war and peace')
  end
end
