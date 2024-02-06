# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PhysicalItem do
  describe '#barcode' do
    it 'takes the barcode from the data provided at initialization' do
      item = described_class.new(item: { 'holding_id' => '10366655', 'id' => '16101155',
                                         'status_at_load' => 'Available', 'barcode' => '33433100641749',
                                         'copy_number' => '1', 'use_statement' => 'In Library Use',
                                         'storage_location' => 'RECAP', 'cgd' => 'Shared',
                                         'collection_code' => 'NA' })
      expect(item.barcode).to eq('33433100641749')
    end
  end
end
