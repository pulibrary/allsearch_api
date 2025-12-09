# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryStaff do
  let(:query_terms) { 'foo' }
  let(:staff_service) { described_class.new(query_terms:) }

  it 'has the correct more_link' do
    expect(staff_service.more_link.value!.to_s).to eq('https://library.princeton.edu/about/staff-directory?combine=foo')
  end

  context 'with accents in in the query terms' do
    let(:query_terms) { '%C3%89t+tu' }

    before do
      stub_request(:get, 'https://lib-jobs.princeton.edu/pul-staff-report.csv')
        .to_return(status: 200,
                   body: file_fixture('library_staff/staff-directory.csv'))

      LibraryStaffLoadingService.new.run
    end

    it 'can search for queries as passed by the controller' do
      our_response = JSON.parse(staff_service.our_response, symbolize_names: true)
      expect(our_response[:records]).not_to be_empty
      expect(our_response[:records].first[:other_fields][:first_name]).to eq('Brutus Ét tu')
    end

    it 'has a valid more link in the JSON response' do
      our_response = JSON.parse(staff_service.our_response, symbolize_names: true)
      expect(our_response[:more]).to eq 'https://library.princeton.edu/about/staff-directory?combine=%C3%89t+tu'
    end
  end
end
