# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/database_models_shared_examples'

RSpec.describe LibraryStaffRecord do
  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
      .to_return(status: 200,
                 body: file_fixture('library_staff/staff-directory.csv'))

    LibraryStaffLoadingService.new.run
  end

  context 'with shared examples' do
    let(:unaccented) { 'Esme' }
    let(:precomposed) { 'Esmé' }
    let(:decomposed) { 'Esmé' }
    let(:database_record) do
      described_class.new_from_csv(
        [
          '000000010', 'brutus', '(555) 222-2222', 'Cat, Brutus', 'Cat', 'Brutus Esmé',
          'brutus@princeton.edu', 'B-300', 'Stokes Library', 'My Department',
          'Library - Collections and Access Services',
          'PCRP - Physical Collections Receipt & Processing Unit', nil, 'Fluffiest cat',
          nil, nil, nil, nil, nil, nil, nil
        ]
      )
    end

    before do
      database_record
    end

    it_behaves_like('a database service')
  end

  describe 'query locates relevant records' do
    it 'finds a record by name' do
      expect(described_class.query('lucy')[0].first_name).to eq('Lucy Fae')
    end

    it 'finds records by title' do
      expect(described_class.query('Nap Coordinator')[0].first_name).to eq('Nimbus Kilgore')
    end

    it 'finds records by office' do
      expect(described_class.query('Forrestal')[0].first_name).to eq('Lucy Fae')
    end

    it 'finds records by building' do
      results = described_class.query('Firestone Library')
      expect(results.length).to eq(3)
      expect(results[0].first_name).to eq('Nimbus Kilgore')
      expect(results[1].first_name).to eq('Spot Tiberius')
      expect(results[2].first_name).to eq('Fred')
    end

    it 'orders by weight' do
      results = described_class.query('Firestone')
      expect(results.length).to eq(3)
      expect(results[0].first_name).to eq('Fred')
      expect(results[1].first_name).to eq('Nimbus Kilgore')
      expect(results[2].first_name).to eq('Spot Tiberius')
    end

    it 'finds records by other entities' do
      results = described_class.query('Center for Global')
      expect(results.length).to eq(1)
      expect(results[0].other_entities).to eq('MS Chadha Center for Global India')
    end
  end
end
