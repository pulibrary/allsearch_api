# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArticleController do
  it 'sanitizes input' do
    stub_summon(query: 'bad%20bin%20bash%20script', fixture: 'article/bash.json')
    get :show, params: { query: '{bad#!/bin/bash<script>}' }
    expect(controller.query.query_terms).to eq('bad bin bash script')
  end

  it 'removes redundant space from query' do
    stub_summon(query: 'war%20and%20peace', fixture: 'article/war_and_peace.json')
    get :show, params: { query: "war   and\tpeace" }
    expect(controller.query.query_terms).to eq('war and peace')
  end
end
