# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SummonApi do
  let(:query_terms) { 'forest' }
  let(:summon_api) { described_class.new(query_terms:) }

  before do
    stub_summon(query: 'forest', fixture: 'summon_api/summon_response.json')
  end

  it 'instantiates a Summon::Service' do
    expect(described_class.new(query_terms:).service).to be_an_instance_of(Summon::Service)
  end

  it 'can query the service' do
    expect(summon_api.service_response).to be_an_instance_of(Summon::Search)
  end

  it 'has a number' do
    expect(summon_api.number).to eq(4_621_075)
  end

  it 'has documents' do
    expect(summon_api.documents).to be_an_instance_of(Array)
    expect(summon_api.documents.size).to eq(3)
    expect(summon_api.documents.first).to be_an_instance_of(Summon::Document)
  end

  it 'excludes Newspaper Articles' do
    facet_value_filter = summon_api.service_response.query.facet_value_filters.first
    expect(facet_value_filter.field_name).to eq('ContentType')
    expect(facet_value_filter.negated?).to be(true)

    expect(facet_value_filter.value).to eq('Newspaper Article')
  end
end
