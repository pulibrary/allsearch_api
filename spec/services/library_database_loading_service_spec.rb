# frozen_string_literal: true

require 'rack_helper'

RSpec.describe LibraryDatabaseLoadingService, :truncate do
  let(:libjobs_response) { file_fixture('libjobs/library-databases.csv') }

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/library-databases.csv')
      .to_return(status: 200, body: libjobs_response)
  end

  it 'creates a new row in the library_database_records table for each CSV row' do
    rom = RomFactory.new.require_rom!
    expect { described_class.new.run }.to change { rom.relations[:library_database_records].count }.by(14)
    third_record = rom.relations[:library_database_records].to_a[2]
    expect(third_record[:name]).to eq('Abzu')
    expect(third_record[:description]).to eq('Database of networked open access data relevant to the ' \
                                             'study and public presentation of the Ancient Near East ' \
                                             'and the Ancient Mediterranean world.')
    expect(third_record[:url]).to eq('http://www.etana.org/abzubib')
    expect(third_record[:subjects]).to be_empty
  end

  it 'is idempotent' do
    rom = RomFactory.new.require_rom!
    described_class.new.run
    expect { described_class.new.run }.not_to(change { rom.relations[:library_database_records].count })
  end

  context 'when file does not have the required headers' do
    let(:libjobs_response) { 'bad response' }

    it 'does not proceed' do
      rom = RomFactory.new.require_rom!
      repo = RepositoryFactory.library_database
      repo.create(libguides_id: 123, name: 'JSTOR')
      expect { described_class.new.run }.not_to(change { rom.relations[:library_database_records].count })
    end
  end

  context 'when a library database in postgres is no longer in the CSV' do
    it 'removes it from the database' do
      rom = RomFactory.new.require_rom!
      repo = RepositoryFactory.library_database
      repo.create(libguides_id: 123, name: 'JSTOR')
      expect(rom.relations[:library_database_records].where(libguides_id: 123).count).to eq 1
      described_class.new.run
      expect(rom.relations[:library_database_records].where(libguides_id: 123).to_a).to be_empty
    end
  end

  context 'when a library database has updated info in the CSV' do
    it 'updates the relevant fields' do
      rom = RomFactory.new.require_rom!
      repo = RepositoryFactory.library_database
      repo.create(libguides_id: 2_938_694, name: 'JSTOR')
      expect(
        rom.relations[:library_database_records].where(libguides_id: 2_938_694).first[:name]
      ).to eq 'JSTOR'
      described_class.new.run
      expect(
        rom.relations[:library_database_records].where(libguides_id: 2_938_694).first[:name]
      ).to eq 'AAPG Datapages'
    end
  end

  context 'when the CSV is suspiciously small relative to the number of database rows' do
    it 'does not proceed' do
      rom = RomFactory.new.require_rom!
      repo = RepositoryFactory.library_database
      30.times { |number| repo.create(libguides_id: number, name: 'JSTOR') }
      expect { described_class.new.run }.not_to(change { rom.relations[:library_database_records].count })
    end
  end
end
