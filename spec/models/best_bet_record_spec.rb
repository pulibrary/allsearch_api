# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe BestBetRecord do
  let(:title) { 'Digital Sanborn Maps' }
  let(:description) { 'My somewhat wordy descriptions' }
  let(:url) { 'https://library.princeton.edu/resource/3720' }
  let(:search_terms) { 'sanborn, sanborn map, sanborn maps' }
  let(:last_update) { 'July 8, 2022' }

  describe 'query scope' do
    it 'finds matches in the search_terms (array) field' do
      doc1 = described_class.create(title:, url:, search_terms: %w[dogs cats])
      described_class.create(title:, url:, search_terms: %w[artichokes asparagus])
      doc3 = described_class.create(title:, url:, search_terms: ['dogs', 'dog food'])
      expect(described_class.query('dogs')).to contain_exactly(doc1, doc3)
    end

    it 'is case-insensitive' do
      doc1 = described_class.create(title:, url:, search_terms: %w[dogs cATs])
      expect(described_class.query('Dogs')).to contain_exactly(doc1)
      expect(described_class.query('cats')).to contain_exactly(doc1)
    end

    it 'works for multi-word queries' do
      doc1 = described_class.create(title:, url:, search_terms: ['new york times'])
      expect(described_class.query('New York Times')).to contain_exactly(doc1)
    end

    context 'when searching for terms with diacritics' do
      # Title uses precomposed version of accent
      let(:title) { 'Année Philologique' }
      let(:precomposed) { "l'Année" }
      let(:unaccented) { "l'Annee" }
      let(:decomposed) { "l'Année" }
      let(:search_terms) { ['annee philologique', "l'annee", "l'annee philologique"] }

      it 'can find the record regardless of diacritics' do
        # These searches also seem to behave differently depending on if they have the "l'" or not
        doc1 = described_class.create!(title:, url:, search_terms:)
        expect(described_class.query(unaccented)).to contain_exactly(doc1) # found
        expect(described_class.query(precomposed)).to contain_exactly(doc1)
        expect(described_class.query(decomposed)).to contain_exactly(doc1)
      end
    end
  end

  describe '#new_from_csv' do
    let(:row) { [title, description, url, search_terms, last_update] }
    let(:record) { described_class.new_from_csv(row) }

    context 'with a fully filled out row' do
      it 'creates a complete record' do
        expect(record.title).to eq(title)
        expect(record.description).to eq(description)
        expect(record.url).to eq(url)
        expect(record.last_update).to be_an_instance_of(Date)
      end
    end

    context 'when missing a title' do
      let(:title) { '' }

      it 'does not create a record and logs an error' do
        allow(Rails.logger).to receive(:error)
        expect(record).to be_nil
        expect(Rails.logger).to have_received(:error).with("Could not create new BestBet for row #{row}: " \
                                                           "Validation failed: Title can't be blank")
      end
    end

    context 'when missing a description' do
      let(:description) { '' }

      it 'still creates the record' do
        allow(Rails.logger).to receive(:error)
        expect(record).to be_an_instance_of(described_class)
        expect(Rails.logger).not_to have_received(:error)
      end
    end

    context 'when missing a url' do
      let(:url) { '' }

      it 'does not create a record and logs an error' do
        allow(Rails.logger).to receive(:error)
        expect(record).to be_nil
        expect(Rails.logger).to have_received(:error).with("Could not create new BestBet for row #{row}: " \
                                                           "Validation failed: Url can't be blank")
      end
    end

    context 'when missing search terms' do
      let(:search_terms) { '' }

      it 'does not create a record and logs an error' do
        allow(Rails.logger).to receive(:error)
        expect(record).to be_nil
        expect(Rails.logger).to have_received(:error).with("Could not create new BestBet for row #{row}: " \
                                                           "Validation failed: Search terms can't be blank")
      end
    end

    context 'when search terms contain precomposed diacritics' do
      let(:search_terms) { "l'Année" }

      it 'normalizes the terms to not contain diacritics' do
        expect(record.search_terms).to contain_exactly("l'Annee")
      end
    end

    context 'when search terms contain decomposed diacritics' do
      let(:search_terms) { "l'Année" }

      it 'normalizes the terms to not contain diacritics' do
        expect(record.search_terms).to contain_exactly("l'Annee")
      end
    end

    context 'when missing a last_update date' do
      let(:last_update) { '' }

      it 'still creates the record' do
        allow(Rails.logger).to receive(:error)
        expect(record).to be_an_instance_of(described_class)
        expect(Rails.logger).not_to have_received(:error)
      end
    end

    context 'when there is a differently formatted last_update date' do
      let(:last_update) { '12/04/2022' }

      it 'still creates the record and logs an info' do
        allow(Rails.logger).to receive(:error)
        allow(Rails.logger).to receive(:info)
        expect(record).to be_an_instance_of(described_class)
        expect(Rails.logger).not_to have_received(:error)
        expect(Rails.logger).to have_received(:info).with("Invalid date for BestBet row: #{row}")
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers
end
