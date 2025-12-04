# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryStaffDocument do
  let(:record) { LibraryStaffRecord.find_by(email: 'brutus@princeton.edu') }
  let(:staff_document) { described_class.new(document: record, doc_keys: []) }

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
      .to_return(status: 200,
                 body: file_fixture('library_staff/staff-directory.csv'))

    LibraryStaffLoadingService.new.run
    record
  end

  it 'can escape names with accents' do
    expect { staff_document.send(:name_to_path) }.not_to raise_error
    expect(staff_document.send(:name_to_path)).to eq('brutus-%C3%A9t-tu-cat')
  end

  describe '#url' do
    let(:record) { LibraryStaffRecord.create(first_name: 'Ufuoma', last_name: 'Abiola') }

    it 'is the url of the staff profile on the drupal website' do
      expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/ufuoma-abiola')
    end

    describe 'when the user has a middle initial' do
      let(:record) { LibraryStaffRecord.create(first_name: 'Ryan D.', last_name: 'Gerber') }

      it 'removes the period after the middle initial' do
        expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/ryan-d-gerber')
      end
    end

    describe 'when the user has an abbreviated first name' do
      let(:record) { LibraryStaffRecord.create(first_name: 'C. Sophia', last_name: 'Liu') }

      it 'removes the period after the first initial' do
        expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/c-sophia-liu')
      end
    end

    describe 'when the user has Jr. at the end of their name' do
      let(:record) { LibraryStaffRecord.create(first_name: 'John E.', last_name: 'Thorpe Jr.') }

      it 'removes the period after Jr' do
        expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/john-e-thorpe-jr')
      end
    end

    describe 'when the user has an apostrophe in their name' do
      let(:record) { LibraryStaffRecord.create(first_name: 'Sadie', last_name: "O'Brien") }

      it 'removes the apostrophe' do
        expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/sadie-obrien')
      end
    end
  end
end
