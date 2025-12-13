# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ArticleDocument do
  let(:doc_keys) { [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields] }
  let(:query_terms) { 'forest' }
  let(:document) { Article.new(query_terms:).documents.first }
  let(:article_document) { described_class.new(document:, doc_keys:) }

  before do
    stub_summon(query: 'forest', fixture: 'article/forest.json')
  end

  it 'has the expected values' do
    expect(article_document.title)
      .to eq('The Rainforests of Cameroon : Experience and Evidence from a Decade of Reform')
    expect(article_document.creator).to eq('Topa, Giuseppe')
    expect(article_document.publisher).to eq('World Bank')
    expect(article_document.id).to eq('10.1596/978-0-8213-7878-6')
    expect(article_document.type).to eq('Book')
    expect(article_document.description).to include('In 1994, the Government of Cameroon')
    expect(article_document.url).to include('princeton.summon.serialssolutions.com/2.0.0/link/0/')
    expect(article_document.publication_date).to eq('2009')
    expect(article_document.publication_year).to eq('2009')
    expect(article_document.fulltext_available).to be('Full-text available')
    expect(article_document.abstract).to include('In 1994, the Government of Cameroon')
    expect(article_document.isxn).to eq('9780821378786')
  end

  context 'with a lot of journal articles' do
    let(:query_terms) { 'potato' }

    before do
      stub_summon(query: 'potato', fixture: 'article/potato.json')
    end

    it 'has the expected_values' do
      expect(article_document.title).to eq('Potato')
      expect(article_document.publication_title).to eq('Plants (Basel)')
      expect(article_document.publication_date).to eq('20221001')
      expect(article_document.publication_year).to eq('2022')
      expect(article_document.volume).to eq('11')
      expect(article_document.issue).to eq('20')
      expect(article_document.type).to eq('Journal Article')
      expect(article_document.isxn).to eq('2223-7747')
    end
  end
end
