# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryDatabaseLoadingService do
  let(:libjobs_response) { file_fixture('libjobs/library-databases.csv') }

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/library-databases.csv')
      .to_return(status: 200, body: libjobs_response)
  end

  it 'creates a new row in the library_database_records table for each CSV row' do
    expect { described_class.new.run }.to change(LibraryDatabaseRecord, :count).by(11)
    expect(LibraryDatabaseRecord.third.name).to eq('Abzu')
    expect(LibraryDatabaseRecord.third.description).to eq('Database of networked open access data relevant to the ' \
                                                          'study and public presentation of the Ancient Near East ' \
                                                          'and the Ancient Mediterranean world.')
    expect(LibraryDatabaseRecord.third.url).to eq('http://www.etana.org/abzubib')
    expect(LibraryDatabaseRecord.third.subjects).to be_empty
  end

  it 'is idempotent' do
    described_class.new.run
    expect { described_class.new.run }.not_to change(LibraryDatabaseRecord, :count)
  end

  context 'when file does not have the required headers' do
    let(:libjobs_response) { 'bad response' }

    it 'does not proceed' do
      LibraryDatabaseRecord.create(libguides_id: 123, name: 'JSTOR')
      expect { described_class.new.run }.not_to(change(LibraryDatabaseRecord, :count))
    end
  end

  context 'when a library database in postgres is no longer in the CSV' do
    it 'removes it from the database' do
      old_record = LibraryDatabaseRecord.create(libguides_id: 123, name: 'JSTOR')
      expect(LibraryDatabaseRecord.where(libguides_id: 123)).to contain_exactly(old_record)
      described_class.new.run
      expect(LibraryDatabaseRecord.where(libguides_id: 123)).to be_empty
    end
  end

  context 'when a library database has updated info in the CSV' do
    it 'updates the relevant fields' do
      LibraryDatabaseRecord.create(libguides_id: 2_938_694, name: 'JSTOR')
      expect(LibraryDatabaseRecord.find_by(libguides_id: 2_938_694).name).to eq 'JSTOR'
      described_class.new.run
      expect(LibraryDatabaseRecord.find_by(libguides_id: 2_938_694).name).to eq 'AAPG Datapages'
    end
  end

  context 'when the CSV is suspiciously small relative to the number of database rows' do
    it 'does not proceed' do
      30.times { |number| LibraryDatabaseRecord.create(libguides_id: number, name: 'JSTOR') }
      expect { described_class.new.run }.not_to(change(LibraryDatabaseRecord, :count))
    end
  end
end
