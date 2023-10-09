# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SummonApiDocument do
  let(:doc_keys) { [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields] }
  let(:query_terms) { 'forest' }
  let(:document) { SummonApi.new(query_terms:).documents.first }
  let(:summon_api_document) { described_class.new(document:, doc_keys:) }

  before do
    stub_summon(query: 'forest', fixture: 'summon_api/forest.json')
  end

  it 'has the expected values' do
    expect(summon_api_document.title)
      .to eq('The Rainforests of Cameroon : Experience and Evidence from a Decade of Reform')
    expect(summon_api_document.creator).to eq('Topa, Giuseppe')
    expect(summon_api_document.publisher).to eq('World Bank')
    expect(summon_api_document.id).to eq('10.1596/978-0-8213-7878-6')
    expect(summon_api_document.type).to eq('Book')
    expect(summon_api_document.description).to include('In 1994, the Government of Cameroon')
    expect(summon_api_document.url).to include('princeton.summon.serialssolutions.com/2.0.0/link/0/')
    expect(summon_api_document.publication_date).to eq('2009')
    expect(summon_api_document.publication_year).to eq(2009)
    expect(summon_api_document.fulltext_available).to be(true)
    expect(summon_api_document.abstract).to include('In 1994, the Government of Cameroon')
    expect(summon_api_document.isxn).to match_array(%w[9780821378786 0821378783])
  end

  context 'with a lot of journal articles' do
    let(:query_terms) { 'potato' }

    before do
      stub_summon(query: 'potato', fixture: 'summon_api/potato.json')
    end

    it 'has the expected_values' do
      expect(summon_api_document.publication_title).to eq('Plants (Basel)')
      expect(summon_api_document.publication_date).to eq('20221001')
      expect(summon_api_document.publication_year).to eq(2022)
      expect(summon_api_document.volume).to eq('11')
      expect(summon_api_document.issue).to eq('20')
      expect(summon_api_document.type).to eq('Journal Article')
      expect(summon_api_document.isxn).to contain_exactly('2223-7747')
    end
  end
end
