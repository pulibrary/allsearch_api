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

  it 'finds the barcode from the holdings_1display' do
    holdings = '{"22513144820006421":{"location_code":"mendel$stacks","location":"Stacks",' \
               '"library":"Mendel Music Library",' \
               '"call_number":"CD- 11175","call_number_browse":"CD- 11175","items":[' \
               '{"holding_id":"22513144820006421","id":"23513144810006421",' \
               '"status_at_load":"1","barcode":"32101052309489","copy_number":"1"}]}}'
    source_data = { holdings_1display: holdings }
    document = described_class.new(document: source_data, doc_keys: [:first_barcode]).to_h
    expect(document[:first_barcode]).to eq '32101052309489'
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

  it 'links to the record url associated with the solr collection' do
    document = described_class.new(document: {}, doc_keys: [])
    expect(document.send(:url)).to eq('https://catalog.princeton.edu/catalog/')
  end

  context 'when on a non-production environment' do
    it 'links to the record url associated with the solr collection' do
      document = described_class.new(document: {}, doc_keys: [],
                                     environment: Environment.new({ 'RAILS_ENV' => 'staging' }))
      expect(document.send(:url)).to eq('https://catalog-staging.princeton.edu/catalog/')
    end
  end

  context 'when alma holdings item is RES_SHARE$IN_RS_REQ' do
    it 'has status Unavailable' do
      holdings = '{"RES_SHARE$IN_RS_REQ":{"library":"Mendel Music Library","items":[{"status_at_load":"1"}]}}'
      source_data = { holdings_1display: holdings, id: '99116004723506421' }
      document = described_class.new(document: source_data, doc_keys: [:first_status]).to_h
      expect(document[:first_status]).to eq 'Unavailable'
    end
  end

  context 'when alma holdings item is in a temporary location' do
    it 'has status View record for Full Availability' do
      holdings = '{"lewis$res":{"library":"Mendel Music Library","items":[{"status_at_load":"1"}]}}'
      source_data = { holdings_1display: holdings, id: '99116004723506421' }
      document = described_class.new(document: source_data, doc_keys: [:first_status]).to_h
      expect(document[:first_status]).to eq 'View record for Full Availability'
    end
  end

  context 'when alma holdings items are all Item In Place' do
    it 'has status Available' do
      holdings = '{"22658690520006421":{"library":"Mendel Music Library","items":[{"status_at_load":"1"}]}}'
      source_data = { holdings_1display: holdings, id: '99116004723506421' }
      document = described_class.new(document: source_data, doc_keys: [:first_status]).to_h
      expect(document[:first_status]).to eq 'Available'
    end

    context 'when otherwise available items have a process type' do
      it 'has status Unavailable' do
        holdings = '{"22658690520006421":{"library":"Mendel Music Library",' \
                   '"items":[{"status_at_load":"1", "process_type":"WORK_ORDER_DEPARTMENT"}]}}'
        source_data = { holdings_1display: holdings, id: '99116004723506421' }
        document = described_class.new(document: source_data, doc_keys: [:first_status]).to_h
        expect(document[:first_status]).to eq 'Unavailable'
      end
    end
  end

  context 'when alma holdings items are all Item Not In Place' do
    it 'has status Unavailable' do
      holdings = '{"22658690520006421":{"library":"Mendel Music Library","items":[{"status_at_load":"0"}]}}'
      source_data = { holdings_1display: holdings, id: '99116004723506421' }
      document = described_class.new(document: source_data, doc_keys: [:first_status]).to_h
      expect(document[:first_status]).to eq 'Unavailable'
    end
  end

  context 'when alma holdings items are a mix of Item In Place and Item Not In Place' do
    it 'has status Some items not available' do
      holdings = '{"22658690520006421":{"library":"Mendel Music Library",' \
                 '"items":[{"status_at_load":"0"}, {"status_at_load":"1"}]}}'
      source_data = { holdings_1display: holdings, id: '99116004723506421' }
      document = described_class.new(document: source_data, doc_keys: [:first_status]).to_h
      expect(document[:first_status]).to eq 'Some items not available'
    end
  end

  context 'when the document is a coin' do
    it 'has a status On-site access' do
      holdings = '{"numismatics":{"location":"Special Collections - Numismatics Collection",' \
                 '"library":"Special Collections","location_code":"rare$num","call_number":"Coin 762",' \
                 '"call_number_browse":"Coin 762"}}'
      source_data = { holdings_1display: holdings, id: 'coin-4905' }
      document = described_class.new(document: source_data, doc_keys: [:first_status]).to_h
      expect(document[:first_status]).to eq 'On-site access'
    end
  end

  context 'when the document is a senior thesis' do
    it 'has a status On-site access' do
      holdings = '{"thesis":{"location":"Mudd Manuscript Library","library":"Mudd Manuscript Library",' \
                 '"location_code":"mudd$stacks","call_number":"AC102 8931","call_number_browse":"AC102 8931"' \
                 ',"dspace":true}}'
      source_data = { holdings_1display: holdings, id: 'dsp016969z278m' }
      document = described_class.new(document: source_data, doc_keys: [:first_status]).to_h
      expect(document[:first_status]).to eq 'On-site access'
    end
  end

  describe '#other_fields' do
    it 'does not include nil values' do
      source_data = { title_display: 'My book', id: 'SCSB-1234' }
      doc_keys = [:title, :other_fields]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:other_fields]).to eq({ online_access_count: '0' })
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

  describe '#resource_url_label' do
    it 'takes description from electronic_portfolio_s if available' do
      source_data = {
        electronic_portfolio_s: ['{"url":"https://example.com", "title": "Gale (1800-present)"}'],
        electronic_access_1display: '{"https://catalog.princeton.edu/catalog/4970874#view":["Digital content"],' \
                                    '"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/x920g047m":"https://figgy.princeton.edu/concern/scanned_resources/e6142376-a3b0-4ec6-a794-3a64f00df533/manifest"}}'
      }
      doc_keys = [:resource_url_label]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:resource_url_label]).to eq('Gale (1800-present)')
    end

    it 'defaults to "Online content" if no description appears in the portfolio' do
      source_data = {
        electronic_portfolio_s: ['{"url":"https://example.com", "title": null}']
      }
      doc_keys = [:resource_url_label]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:resource_url_label]).to eq('Online content')
    end

    it 'takes description from electronic_access_1display as a fallback' do
      source_data = {
        electronic_access_1display: '{"https://catalog.princeton.edu/catalog/4970874#view":["Digital content"],' \
                                    '"iiif_manifest_paths":{"http://arks.princeton.edu/ark:/88435/x920g047m":"https://figgy.princeton.edu/concern/scanned_resources/e6142376-a3b0-4ec6-a794-3a64f00df533/manifest"}}'
      }
      doc_keys = [:resource_url_label]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:resource_url_label]).to eq('Digital content')
    end

    it 'does not have a label if there is no electronic_access_1display or electronic_portfolio_s' do
      doc_keys = [:resource_url_label]
      document = described_class.new(document: {}, doc_keys:).to_h
      expect(document[:resource_url_label]).to be_nil
    end
  end
end
