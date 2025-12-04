# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryWebsiteDocument do
  let(:doc_keys) { [:title, :id, :type, :description, :url, :other_fields] }
  let(:query_terms) { 'firestone' }
  let(:document) { LibraryWebsite.new(query_terms:).documents.first }
  let(:website_document) { described_class.new(document:, doc_keys:) }

  before do
    stub_website(query: 'firestone', fixture: 'library_website/firestone.json')
  end

  it 'has the expected values' do
    expect(website_document.title).to eq('Third Level Page Two')
    expect(website_document.id).to eq('151')
    expect(website_document.type).to eq('ps_basic_page')
    expect(website_document.description)
      .to include('Nullam eget diam faucibus elit lobortis viverra a vel justo. Sed eget massa auctor.')
    expect(website_document.url).to include('library.princeton.edu/services/')
  end
end
