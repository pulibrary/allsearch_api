# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Normalizer do
  describe '#without_diacritics' do
    it 'removes precomposed diacritics' do
      expect(described_class.new("l'Année").without_diacritics).to eq("l'Annee")
    end

    it 'removes decomposed diacritics' do
      expect(described_class.new("l'Année").without_diacritics).to eq("l'Annee")
    end
  end
end
