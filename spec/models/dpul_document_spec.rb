# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DpulDocument do
  describe '#other_fields' do
    it 'does not include nil values' do
      source_data = { readonly_title_ssim: 'My book', id: 'SCSB-1234' }
      doc_keys = [:title, :other_fields]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:other_fields]).to eq({})
    end
  end
end
