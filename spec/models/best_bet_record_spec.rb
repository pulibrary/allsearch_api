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
  end
end
