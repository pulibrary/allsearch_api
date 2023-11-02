# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryWebsite do
  let(:query_terms) { 'firestone' }
  let(:website) { described_class.new(query_terms:) }

  before do
    stub_website(query: 'firestone', fixture: 'library_website/firestone.json')
  end

  it 'has a number' do
    expect(website.number).to eq(4)
  end

  it 'has documents' do
    expect(website.documents).to be_an_instance_of(Array)
    expect(website.documents.size).to eq(3)
  end
end
