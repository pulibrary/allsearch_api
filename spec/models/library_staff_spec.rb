# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryStaff do
  let(:query_terms) { 'foo' }
  let(:staff_service) { described_class.new(query_terms:) }

  it 'has the correct more_link' do
    expect(staff_service.more_link.to_s).to eq('https://library.princeton.edu/about/staff-directory?combine=foo')
  end

  context 'with accents in in the query terms' do
    context 'with precomposed accents' do
      let(:query_terms) { 'Esmé' }

      before do
        stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
          .to_return(status: 200,
                     body: file_fixture('library_staff/staff-directory.csv'))

        LibraryStaffLoadingService.new.run
      end

      it 'can search for queries as passed by the controller' do
        expect(staff_service.library_staff_service_response).not_to be_empty
        expect(staff_service.library_staff_service_response.first.first_name).to eq('Esmé')
      end
    end

    context 'with decomposed accents' do
      let(:query_terms) { 'Esmé' }

      before do
        stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
          .to_return(status: 200,
                     body: file_fixture('library_staff/staff-directory.csv'))

        LibraryStaffLoadingService.new.run
      end

      it 'can search for queries as passed by the controller' do
        pending('Fixing search for decomposed accents')
        expect(staff_service.library_staff_service_response).not_to be_empty
        expect(staff_service.library_staff_service_response.first.first_name).to eq('Esmé')
      end
    end
  end
end
