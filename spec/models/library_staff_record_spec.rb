# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryStaffRecord do
  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/staff-directory.csv')
      .to_return(status: 200,
                 body: file_fixture('library_staff/staff-directory.csv'))

    LibraryStaffLoadingService.new.run
  end

  describe 'query locates relevant records' do
    it 'finds a record by name' do
      expect(described_class.query('lucy')[0].first_name).to eq('Lucy')
    end

    it 'finds records by building' do
      expect(described_class.query('Firestone Library').length).to be(2)
    end

    it 'finds records by title' do
      expect(described_class.query('Nap Coordinator')[0].first_name).to eq('Nimbus')
    end

    it 'finds records by office' do
      expect(described_class.query('Forrestal')[0].first_name).to eq('Lucy')
    end

    it 'finds records by building' do
      results = described_class.query('Firestone Library')
      expect(results.length).to be(2)
      expect(results[0].first_name).to eq('Nimbus')
      expect(results[1].first_name).to eq('Spot')
    end
  end
end
