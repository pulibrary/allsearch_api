# frozen_string_literal: true

require 'rails_helper'
# This controller behaves differently from the other ServiceControllers, so not including shared examples
RSpec.describe LibanswersController do
  before do
    stub_libanswers(query: 'bad+bin+bash+script', fixture: 'libanswers/printer.json')
    stub_libanswers(query: 'war+and+peace', fixture: 'libanswers/printer.json')
    stub_libanswers(query: '%2525', fixture: 'libanswers/printer.json')
    stub_libanswers(query: '读', fixture: 'libanswers/printer.json')
  end

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

  it 'does not throw an error when the url contains numbers and the percent sign' do
    get :show, params: { query: '%25' }

    expect(response).to have_http_status(:ok)
    expect(controller.query.query_terms).to eq('%2525')
  end
end
