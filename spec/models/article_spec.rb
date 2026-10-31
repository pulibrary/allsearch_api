# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Article do
  let(:query_terms) { 'forest' }
  let(:article) { described_class.new }

  before do
    stub_summon(query: 'forest', fixture: 'article/forest.json')
  end

  it 'can query the service' do
    expect(article.service_search(query_terms:)).to be_an_instance_of(Summon::Search)
  end

  it 'has a number' do
    expect(JSON.parse(article.our_response(query_terms:))['number']).to eq(4_621_075)
  end

  it 'has documents' do
    expect(JSON.parse(article.our_response(query_terms:))['records'].size).to eq(3)
  end

  it 'excludes Newspaper Articles' do
    facet_value_filter = article.service_search(query_terms:).query.facet_value_filters.first
    expect(facet_value_filter.field_name).to eq('ContentType')
    expect(facet_value_filter.negated?).to be(true)

    expect(facet_value_filter.value).to eq('Newspaper Article')
  end

  it 'does not make excessive queries when compiling our response' do
    article.our_response(query_terms:)
    expect(WebMock).to have_requested(:get, %r{http://api\.summon\.serialssolutions\.com.*}).times(1)
  end

  it 'is reusable across multiple queries' do
    stub_summon(query: 'desert', fixture: 'article/forest.json')
    expect(JSON.parse(article.our_response(query_terms: 'forest'))['number']).to eq(4_621_075)
    expect(JSON.parse(article.our_response(query_terms: 'desert'))['number']).to eq(4_621_075)
  end
end
