# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CatalogDocument do
  it 'finds the library from the holdings_1display' do
    holdings = '{"22513144820006421":{"location_code":"mendel$stacks","location":"Stacks",' \
               '"library":"Mendel Music Library",' \
               '"call_number":"CD- 11175","call_number_browse":"CD- 11175","items":[' \
               '{"holding_id":"22513144820006421","id":"23513144810006421",' \
               '"status_at_load":"1","barcode":"32101052309489","copy_number":"1"}]}}'
    source_data = { holdings_1display: holdings }
    document = described_class.new(document: source_data, doc_keys: [:library]).to_h
    expect(document[:library]).to eq 'Mendel Music Library'
  end

  describe '#other_fields' do
    it 'does not include nil values' do
      source_data = { title_display: 'My book', id: 'SCSB-1234' }
      doc_keys = [:title, :other_fields]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:other_fields]).to eq({})
    end
  end
end
