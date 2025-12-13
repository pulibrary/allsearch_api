# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Article do
  let(:query_terms) { 'forest' }
  let(:article) { described_class.new(query_terms:) }

  before do
    stub_summon(query: 'forest', fixture: 'article/forest.json')
  end

  it 'instantiates a Summon::Service' do
    expect(described_class.new(query_terms:).service).to be_an_instance_of(Summon::Service)
  end

  it 'can query the service' do
    expect(article.service_response).to be_an_instance_of(Summon::Search)
  end

  it 'has a number' do
    expect(article.number).to eq(4_621_075)
  end

  it 'has documents' do
    expect(article.documents).to be_an_instance_of(Array)
    expect(article.documents.size).to eq(3)
    expect(article.documents.first).to be_an_instance_of(Summon::Document)
  end

  it 'excludes Newspaper Articles' do
    facet_value_filter = article.service_response.query.facet_value_filters.first
    expect(facet_value_filter.field_name).to eq('ContentType')
    expect(facet_value_filter.negated?).to be(true)

    expect(facet_value_filter.value).to eq('Newspaper Article')
  end

  it 'does not make excessive queries when compiling our response' do
    article.our_response
    expect(WebMock).to have_requested(:get, %r{http://api\.summon\.serialssolutions\.com.*}).times(1)
  end
end
