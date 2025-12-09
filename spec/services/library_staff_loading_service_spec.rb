# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryStaffLoadingService, :truncate do
  let(:libjobs_response) { file_fixture('library_staff/staff-directory.csv') }

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
      .to_return(status: 200, body: libjobs_response)
  end

  it 'creates new rows in the library_staff table for each CSV row' do
    rom = Rails.application.config.rom
    expect { described_class.new.run }.to change { rom.relations[:library_staff_records].count }.by(5)
    third_record = rom.relations[:library_staff_records].to_a[2]
    fourth_record = rom.relations[:library_staff_records].to_a[3]
    expect(third_record[:puid]).to eq(0o00000003)
    expect(third_record[:netid]).to eq('tiberius')
    expect(third_record[:phone]).to eq('(555) 222-2222')
    expect(third_record[:name]).to eq('Adams, Tiberius')
    expect(third_record[:last_name]).to eq('Adams')
    expect(third_record[:first_name]).to eq('Spot Tiberius')
    expect(third_record[:pronouns]).to eq('they/them')

    # The CSV we get from airtable via lib_jobs does not contain middle names as a
    # separate field, they are concatenated into the first_name.  So nil values in
    # this field are to be expected.
    expect(third_record[:middle_name]).to be_nil

    expect(third_record[:title]).to eq('Lead Hairball Engineer')
    expect(third_record[:library_title]).to eq('Lead Hairball Engineer')
    expect(third_record[:email]).to eq('tiberius@princeton.edu')
    expect(third_record[:department]).to eq('My Department')
    expect(third_record[:office]).to eq('B-300')
    expect(third_record[:building]).to eq('Firestone Library')
    expect(fourth_record[:first_name]).to eq('Brutus Ét tu')
    expect(fourth_record[:pronouns]).to be_nil
  end

  it 'is idempotent' do
    described_class.new.run
    rom = Rails.application.config.rom
    expect { described_class.new.run }.not_to(change { rom.relations[:library_staff_records].count })
  end

  context 'when file does not have the required headers' do
    let(:libjobs_response) { 'bad response' }

    it 'does not proceed' do
      described_class.new.run
      # Create a record that would typically be deleted as part of running
      # this service, since it is not in the CSV data
      rom = Rails.application.config.rom
      repo = RepositoryFactory.library_staff
      repo.create(puid: 0o00000004, netid: 'notourcat', name: 'Cat, Not Our',
                  title: 'Outside Specialist', library_title: 'Outside Specialist',
                  email: 'outside@princeton.edu', department: 'None')
      expect { described_class.new.run }.not_to(change { rom.relations[:library_staff_records].count })
    end
  end

  context 'when the file has extra headers' do
    let(:libjobs_response) { file_fixture('library_staff/staff-directory_extra_headers.csv') }

    it 'proceeds and logs an info' do
      described_class.new.run
      # Create a record that would typically be deleted as part of running
      # this service, since it is not in the CSV data
      rom = Rails.application.config.rom
      repo = RepositoryFactory.library_staff
      repo.create(puid: 0o00000004, netid: 'notourcat', name: 'Cat, Not Our',
                  title: 'Outside Specialist', library_title: 'Outside Specialist',
                  email: 'outside@princeton.edu', department: 'None')
      expect { described_class.new.run }.to(change { rom.relations[:library_staff_records].count })
    end
  end

  context 'when a staff member in postgres is no longer in the CSV' do
    it 'removes them from the database' do
      rom = Rails.application.config.rom
      repo = RepositoryFactory.library_staff
      repo.create(puid: 0o00000004, netid: 'notourcat', name: 'Cat, Not Our',
                  title: 'Outside Specialist', library_title: 'Outside Specialist',
                  email: 'outside@princeton.edu', department: 'None')
      expect(rom.relations[:library_staff_records].where(puid: 0o00000004).count).to eq(1)
      described_class.new.run
      expect(rom.relations[:library_staff_records].where(puid: 0o00000004).to_a).to be_empty
    end
  end

  context 'when a staff member has updated info in the CSV' do
    it 'updates the relevant fields' do
      rom = Rails.application.config.rom
      repo = RepositoryFactory.library_staff
      repo.create(puid: 0o00000003, netid: 'tiberius', first_name: 'Spot Tiberius', name: 'Adams, Spot',
                  title: 'Lead Hairball Engineer', library_title: 'Lead Hairball Engineer',
                  email: 'tiberius@princeton.edu',
                  department: 'Library - Collections and Access Services')
      expect(rom.relations[:library_staff_records].where(first_name: 'Spot Tiberius').first.name).to eq 'Adams, Spot'
      described_class.new.run
      expect(rom.relations[:library_staff_records].where(first_name: 'Spot Tiberius').first.name)
        .to eq 'Adams, Tiberius'
    end
  end

  context 'when there are blank lines in the CSV' do
    let(:libjobs_response) { file_fixture('library_staff/staff-directory-blank-lines.csv') }

    it 'creates records for any complete lines in the CSV' do
      rom = Rails.application.config.rom
      expect { described_class.new.run }.to change { rom.relations[:library_staff_records].count }.by(1)
    end
  end
end
