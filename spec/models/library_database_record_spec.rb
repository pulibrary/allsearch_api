# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/database_models_shared_examples'

RSpec.describe LibraryDatabaseRecord do
  describe '::new_from_csv' do
    it 'generates a new database record from the CSV row' do
      csv_data = ['123', 'Academic Search', 'A very good database',
                  'Academic Search Plus; Academic Search Premier',
                  'http://ebsco.com',
                  'https://libguides.princeton.edu/resource/12345',
                  'Civil Engineering;Energy;Environment']
      described_class.new_from_csv(csv_data)
      record = described_class.last
      expect(record.libguides_id).to eq(123)
      expect(record.name).to eq('Academic Search')
      expect(record.description).to eq('A very good database')
      expect(record.alt_names).to contain_exactly('Academic Search Plus', 'Academic Search Premier')
      expect(record.url).to eq('http://ebsco.com')
      expect(record.friendly_url).to eq('https://libguides.princeton.edu/resource/12345')
      expect(record.subjects).to contain_exactly('Civil Engineering', 'Energy', 'Environment')
    end
  end
end
