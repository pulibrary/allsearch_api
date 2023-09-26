# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibanswersController do
  it 'sanitizes input' do
    stub_libanswers(query: 'bad+bin+bash+script', fixture: 'libanswers/printer.json')
    get :show, params: { query: '{bad#!/bin/bash<script>}' }
    expect(controller.query.query_terms).to eq('bad+bin+bash+script')
  end

  it 'removes redundant space from query' do
    stub_libanswers(query: 'war+and+peace', fixture: 'libanswers/printer.json')
    get :show, params: { query: "war   and\tpeace" }
    expect(controller.query.query_terms).to eq('war+and+peace')
  end
end
