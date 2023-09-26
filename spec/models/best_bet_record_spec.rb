# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BestBetRecord do
  describe 'query scope' do
    it 'finds matches in the search_terms (array) field' do
      doc1 = described_class.create(search_terms: %w[dogs cats])
      described_class.create(search_terms: %w[artichokes asparagus])
      doc3 = described_class.create(search_terms: ['dogs', 'dog food'])
      expect(described_class.query('dogs')).to contain_exactly(doc1, doc3)
    end

    it 'is case-insensitive' do
      doc1 = described_class.create(search_terms: %w[dogs cATs])
      expect(described_class.query('Dogs')).to contain_exactly(doc1)
      expect(described_class.query('cats')).to contain_exactly(doc1)
    end

    it 'works for multi-word queries' do
      doc1 = described_class.create(search_terms: ['new york times'])
      expect(described_class.query('New York Times')).to contain_exactly(doc1)
    end
  end
end
