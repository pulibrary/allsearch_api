# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibguidesDocument do
  describe 'creator' do
    it 'can take from the owner field' do
      document = { 'owner' => { 'first_name' => 'First', 'last_name' => 'Last' } }
      libguides_document = described_class.new(document:, doc_keys: [:creator])
      expect(libguides_document.to_h[:creator]).to eq 'First Last'
    end

    it 'is not included if there is no owner information' do
      document = { 'owner' => {} }
      libguides_document = described_class.new(document:, doc_keys: [:creator])
      expect(libguides_document.to_h.key?(:creator)).to be false
    end
  end
end
