# frozen_string_literal: true

require 'rack_helper'

RSpec.describe LibraryStaffRelation do
  let(:rom) { Rails.application.config.rom }
  let(:library_staff) { rom.relations[:library_staff_records] }

  describe '#query' do
    before do
      repo = LibraryStaffRepository.new(rom)
      csv = CSV.read Rails.root.join('spec/fixtures/files/library_staff/staff-directory.csv'), headers: true
      repo.new_from_csv(csv)
    end

    let(:lucy) { library_staff.where(puid: '000000001').one }
    let(:nimbus) { library_staff.where(puid: '000000002').one }

    it 'finds records by name' do
      expect(library_staff.query('Lucy')).to contain_exactly(lucy)
    end

    it 'finds records by title' do
      expect(library_staff.query('Nap Coordinator')).to contain_exactly(nimbus)
    end

    it 'finds records by office' do
      expect(library_staff.query('Forrestal')).to contain_exactly(lucy)
    end

    it 'finds records by building' do
      results = library_staff.query('Firestone Library').to_a
      expect(results.count).to eq(3)
      expect(results[0].first_name).to eq('Nimbus Kilgore')
      expect(results[1].first_name).to eq('Spot Tiberius')
      expect(results[2].first_name).to eq('Fred')
    end

    it 'orders by weight' do
      results = library_staff.query('Firestone').to_a
      expect(results.count).to eq(3)
      expect(results[0].first_name).to eq('Fred')
      expect(results[1].first_name).to eq('Nimbus Kilgore')
      expect(results[2].first_name).to eq('Spot Tiberius')
    end

    it 'finds records by other entities' do
      results = library_staff.query('Center for Global').to_a
      expect(results.count).to eq(1)
      expect(results[0].other_entities).to eq('MS Chadha Center for Global India')
    end
  end

  describe 'searching by library_title' do
    before do
      repo = LibraryStaffRepository.new(rom)
      csv = CSV.read Rails.root.join('spec/fixtures/files/library_staff/engineering-staff-directory.csv'), headers: true
      repo.new_from_csv(csv)
    end

    it 'ranks people with engineering in their title higher' do
      results = library_staff.query('engineering librarian').to_a
      names = results.map(&:name)
      expect(names[0..2]).to include('Aspen Dremel')
      expect(names[0..2]).to include('Zachary Mural')
    end

    it 'includes someone without librarian in their title' do
      results = library_staff.query('engineering librarian').to_a
      names = results.map(&:name)
      expect(names).to include('Crystal Passion')
    end

    it 'does not include software engineers' do
      results = library_staff.query('engineering librarian').to_a
      names = results.map(&:name)
      expect(names).not_to include('Max Kilmer')
    end
  end
end
