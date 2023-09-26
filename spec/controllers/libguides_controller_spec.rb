# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibguidesController do
  it 'sanitizes input' do
    stub_libguides(query: 'bad%20bin%20bash%20script', fixture: 'libguides/asian_american_studies.json')
    get :show, params: { query: '{bad#!/bin/bash<script>}' }
    expect(controller.query.query_terms).to eq('bad bin bash script')
  end

  it 'removes redundant space from query' do
    stub_libguides(query: 'war and peace', fixture: 'libguides/asian_american_studies.json')
    get :show, params: { query: "war   and\tpeace" }
    expect(controller.query.query_terms).to eq('war and peace')
  end
end
