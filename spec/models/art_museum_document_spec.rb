# frozen_string_literal: true

require 'spec_helper'

describe ArtMuseumDocument do
  describe '#to_h' do
    it 'includes the first IIIF url from a primary image array' do
      original = { _id: '12345', _source: { primaryimage: ['https://media.artmuseum.princeton.edu/iiif/3/collection/INV03296'] } }
      our_hash = described_class.new(document: original, doc_keys: [:other_fields]).to_h
      expect(our_hash[:other_fields][:primary_image]).to eq 'https://media.artmuseum.princeton.edu/iiif/3/collection/INV03296'
    end

    it 'includes a IIIF url that is not in an array' do
      original = { _id: '12345', _source: { primaryimage: 'https://media.artmuseum.princeton.edu/iiif/3/collection/INV03296' } }
      our_hash = described_class.new(document: original, doc_keys: [:other_fields]).to_h
      expect(our_hash[:other_fields][:primary_image]).to eq 'https://media.artmuseum.princeton.edu/iiif/3/collection/INV03296'
    end

    it 'ignores primary image that is an empty string' do
      original = { _id: '12345', _source: { primaryimage: '' } }
      our_hash = described_class.new(document: original, doc_keys: [:other_fields]).to_h
      expect(our_hash[:other_fields][:primary_image]).to be_nil
    end

    it 'can create an empty other_fields' do
      original = { _id: '12345', _source: {} }
      our_hash = described_class.new(document: original, doc_keys: [:other_fields]).to_h
      expect(our_hash[:other_fields]).to eq({})
    end
  end
end
