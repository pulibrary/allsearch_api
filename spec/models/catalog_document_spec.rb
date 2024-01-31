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
    document = described_class.new(document: source_data, doc_keys: [:first_library]).to_h
    expect(document[:first_library]).to eq 'Mendel Music Library'
  end

  it 'can find two call numbers' do
    holdings = '{"11193682":{"location_code":"scsbhl","location":"Remote Storage","library":"ReCAP",' \
               '"call_number":"LG395.S576 F66 1997x","call_number_browse":"LG395.S576 F66 1997x",' \
               '"items":[{"holding_id":"11193682","id":"16918615","status_at_load":"Available",' \
               '"barcode":"HX1VG3","storage_location":"HD","cgd":"Shared","collection_code":"HW"}]},' \
               '"11193683":{"location_code":"scsbhl","location":"Remote Storage","library":"ReCAP",' \
               '"call_number":"MLC-C","call_number_browse":"MLC-C","items":[{"holding_id":"11193683",' \
               '"id":"21272199","status_at_load":"Available","barcode":"HYAJC3","storage_location":"HD",' \
               '"cgd":"Uncommittable","collection_code":"HY"}]}}'
    source_data = { holdings_1display: holdings }
    document = described_class.new(document: source_data, doc_keys: [:first_call_number, :second_call_number]).to_h
    expect(document[:first_call_number]).to eq 'LG395.S576 F66 1997x'
    expect(document[:second_call_number]).to eq 'MLC-C'
  end

  describe '#other_fields' do
    it 'does not include nil values' do
      source_data = { title_display: 'My book', id: 'SCSB-1234' }
      doc_keys = [:title, :other_fields]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:other_fields]).to eq({})
    end
  end

  describe '#resource_url' do
    it 'takes url from electronic_portfolio_s if available' do
      source_data = {
        electronic_portfolio_s: ['{"url":"https://example.com"}'],
        electronic_access_1display: '{"https://catalog.princeton.edu/catalog/4970874#view":["Digital content"],' \
                                    '"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/x920g047m":"https://figgy.princeton.edu/concern/scanned_resources/e6142376-a3b0-4ec6-a794-3a64f00df533/manifest"}}'
      }
      doc_keys = [:resource_url]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:resource_url]).to eq('https://example.com')
    end

    it 'takes url from electronic_access_1display as a fallback' do
      source_data = {
        electronic_access_1display: '{"https://catalog.princeton.edu/catalog/4970874#view":["Digital content"],' \
                                    '"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/x920g047m":"https://figgy.princeton.edu/concern/scanned_resources/e6142376-a3b0-4ec6-a794-3a64f00df533/manifest"}}'
      }
      doc_keys = [:resource_url]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:resource_url]).to eq('https://catalog.princeton.edu/catalog/4970874#view')
    end
  end
end
