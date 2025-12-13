# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DpulDocument do
  describe '#other_fields' do
    it 'does not include nil values' do
      source_data = { readonly_title_ssim: 'My book', id: 'SCSB-1234' }
      doc_keys = [:title, :other_fields]
      document = described_class.new(document: source_data, doc_keys:).to_h
      expect(document[:other_fields]).to eq({})
    end
  end

  it 'links to the record url associated with the solr collection' do
    document = described_class.new(document: {}, doc_keys: [])
    expect(document.send(:url)).to eq('https://dpul.princeton.edu/catalog/')
  end

  context 'when on a non-production environment' do
    it 'links to the record url associated with the solr collection' do
      document = described_class.new(document: {}, doc_keys: [],
                                     allsearch_config: { dpul: { subdomain: 'dpul-staging' } })
      expect(document.send(:url)).to eq('https://dpul-staging.princeton.edu/catalog/')
    end
  end
end
