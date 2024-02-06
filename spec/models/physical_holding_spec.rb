# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhysicalHolding do
  describe 'barcode' do
    it 'takes the value from the first item' do
      holding_data = {
        'items' => [
          { 'barcode' => 'barcode1' },
          { 'barcode' => 'barcode2' }
        ]
      }
      holding = described_class.new holding_id: '123',
                                    holding_data:,
                                    document_id: '456'
      expect(holding.barcode).to eq('barcode1')
    end
  end
end
