# frozen_string_literal: true

RSpec.shared_examples 'a service controller' do
  let(:bad_script) { '{bad#!/bin/bash<script>}' }
  let(:simplified_chinese_cat) { '读' }
  let(:redundant_spaces) { "war   and\tpeace" }
  let(:percent_sign) { '%25' }
  let(:query_terms) do
    [
      bad_script,
      simplified_chinese_cat,
      redundant_spaces,
      percent_sign
    ]
  end

  it 'sanitizes input' do
    get :show, params: { query: bad_script }

    expect(response).to have_http_status(:ok)
    expect(controller.query.query_terms).to eq('bad bin bash script')
  end

  it 'removes redundant space from query' do
    get :show, params: { query: "war   and\tpeace" }

    expect(response).to have_http_status(:ok)
    expect(controller.query.query_terms).to eq('war and peace')
  end

  it 'does not throw an error when the url contains numbers and the percent sign' do
    get :show, params: { query: '%25' }

    expect(response).to have_http_status(:ok)
    expect(controller.query.query_terms).to eq('%25')
  end

  it 'does not raise an error' do
    expect do
      query_terms.each do |term|
        get :show, params: { query: term }
      end
    end.not_to raise_exception
  end
end
