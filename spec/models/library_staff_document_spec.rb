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
end
