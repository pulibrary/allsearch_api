# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryStaffLoadingService do
  let(:libjobs_response) { file_fixture('library_staff/staff-directory.csv') }

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
      .to_return(status: 200, body: libjobs_response)
  end

  it 'creates new rows in the library_staff table for each CSV row' do
    expect { described_class.new.run }.to change(LibraryStaffRecord, :count).by(4)
    expect(LibraryStaffRecord.third.puid).to eq(0o00000003)
    expect(LibraryStaffRecord.third.netid).to eq('tiberius')
    expect(LibraryStaffRecord.third.phone).to eq('(555) 222-2222')
    expect(LibraryStaffRecord.third.name).to eq('Adams, Tiberius')
    expect(LibraryStaffRecord.third.last_name).to eq('Adams')
    expect(LibraryStaffRecord.third.first_name).to eq('Spot Tiberius')

    # The CSV we get from airtable via lib_jobs does not contain middle names as a
    # separate field, they are concatenated into the first_name.  So nil values in
    # this field are to be expected.
    expect(LibraryStaffRecord.third.middle_name).to be_nil

    expect(LibraryStaffRecord.third.title).to eq('Lead Hairball Engineer')
    expect(LibraryStaffRecord.third.library_title).to eq('Lead Hairball Engineer')
    expect(LibraryStaffRecord.third.email).to eq('tiberius@princeton.edu')
    expect(LibraryStaffRecord.third.department).to eq('My Department')
    expect(LibraryStaffRecord.third.office).to eq('B-300')
    expect(LibraryStaffRecord.third.building).to eq('Firestone Library')
    expect(LibraryStaffRecord.fourth.first_name).to eq('Brutus The')
  end

  it 'is idempotent' do
    described_class.new.run
    expect { described_class.new.run }.not_to change(LibraryStaffRecord, :count)
  end

  context 'when file does not have the required headers' do
    let(:libjobs_response) { 'bad response' }

    it 'does not proceed' do
      described_class.new.run
      # Create a record that would typically be deleted as part of running
      # this service, since it is not in the CSV data
      LibraryStaffRecord.create(puid: 0o00000004, netid: 'notourcat', name: 'Cat, Not Our',
                                title: 'Outside Specialist', library_title: 'Outside Specialist',
                                email: 'outside@princeton.edu', department: 'None')
      expect { described_class.new.run }.not_to(change(LibraryStaffRecord, :count))
    end
  end

  context 'when a staff member in postgres is no longer in the CSV' do
    it 'removes them from the database' do
      old_record = LibraryStaffRecord.create(puid: 0o00000004, netid: 'notourcat', name: 'Cat, Not Our',
                                             title: 'Outside Specialist', library_title: 'Outside Specialist',
                                             email: 'outside@princeton.edu', department: 'None')
      expect(LibraryStaffRecord.where(puid: 0o00000004)).to contain_exactly(old_record)
      described_class.new.run
      expect(LibraryStaffRecord.where(puid: 0o00000004)).to be_empty
    end
  end

  context 'when a staff member has updated info in the CSV' do
    it 'updates the relevant fields' do
      LibraryStaffRecord.create(puid: 0o00000003, netid: 'tiberius', first_name: 'Spot Tiberius', name: 'Adams, Spot',
                                title: 'Lead Hairball Engineer', library_title: 'Lead Hairball Engineer',
                                email: 'tiberius@princeton.edu',
                                department: 'Library - Collections and Access Services')
      expect(LibraryStaffRecord.find_by(first_name: 'Spot Tiberius').name).to eq 'Adams, Spot'
      described_class.new.run
      expect(LibraryStaffRecord.find_by(first_name: 'Spot Tiberius').name).to eq 'Adams, Tiberius'
    end
  end

  context 'when there are blank lines in the CSV' do
    let(:libjobs_response) { file_fixture('library_staff/staff-directory-blank-lines.csv') }

    it 'creates records for any complete lines in the CSV' do
      expect { described_class.new.run }.to change(LibraryStaffRecord, :count).by(1)
    end
  end
end
