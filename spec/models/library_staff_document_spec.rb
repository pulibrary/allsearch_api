# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryStaffDocument do
  let(:record) { {
    first_name: 'Brutus Ét tu',
    last_name: 'Cat',
    puid: '123456',
    netid: 'bettu',
    phone: '609-555-1234'
  } }
  let(:staff_document) { described_class.new(record) }

  before do
    stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
      .to_return(status: 200,
                 body: file_fixture('library_staff/staff-directory.csv'))

    LibraryStaffLoadingService.new.run
  end

  it 'can escape names with accents' do
    expect { staff_document.send(:name_to_path) }.not_to raise_error
    expect(staff_document.send(:name_to_path)).to eq('brutus-%C3%A9t-tu-cat')
  end

  describe '#url' do
    let(:record) { {
      first_name: 'Ufuoma',
      last_name: 'Abiola',
      puid: '654321',
      netid: 'uabiola',
      phone: '609-555-4321'
    } }

    it 'is the url of the staff profile on the drupal website' do
      expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/ufuoma-abiola')
    end

    describe 'when the user has a middle initial' do
      let(:record) { {
        first_name: 'Ryan D.',
        last_name: 'Gerber',
        puid: '112233',
        netid: 'rdgerber',
        phone: '609-555-6789'
      } }

      it 'removes the period after the middle initial' do
        expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/ryan-d-gerber')
      end
    end

    describe 'when the user has an abbreviated first name' do
      let(:record) { {
        first_name: 'C. Sophia',
        last_name: 'Liu',
        puid: '445566',
        netid: 'csophialiu',
        phone: '609-555-9876'
      } }

      it 'removes the period after the first initial' do
        expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/c-sophia-liu')
      end
    end

    describe 'when the user has Jr. at the end of their name' do
      let(:record) { {
        first_name: 'John E.',
        last_name: 'Thorpe Jr.',
        puid: '778899',
        netid: 'jethorpe',
        phone: '609-555-2468'
      } }

      it 'removes the period after Jr' do
        expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/john-e-thorpe-jr')
      end
    end

    describe 'when the user has an apostrophe in their name' do
      let(:record) { {
        first_name: 'Sadie',
        last_name: "O'Brien",
        puid: '998877',
        netid: 'sobrien',
        phone: '609-555-1357'
      } }

      it 'removes the apostrophe' do
        expect(staff_document.send(:url).to_s).to eq('https://library.princeton.edu/about/staff-directory/sadie-obrien')
      end
    end
  end
end
