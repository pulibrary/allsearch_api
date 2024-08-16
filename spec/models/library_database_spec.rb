# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryDatabase do
  let(:query_terms) { 'foo' }
  let(:db_service) { described_class.new(query_terms:) }

  it 'has the correct more_link' do
    expect(db_service.more_link.to_s).to eq('https://libguides.princeton.edu/az.php?q=foo')
  end

  context 'with accents in in the query terms' do
    # URL escaped version of Kōbunsō Taika Koshomoku
    let(:query_terms) { 'K%C5%8Dbuns%C5%8D%20Taika%20Koshomoku' }

    let(:libjobs_response) { file_fixture('libjobs/library-databases.csv') }

    before do
      stub_request(:get, 'https://lib-jobs.princeton.edu/library-databases.csv')
        .to_return(status: 200, body: libjobs_response)
      LibraryDatabaseLoadingService.new.run
    end

    it 'can search for queries as passed by the controller' do
      expect(db_service.library_database_service_response).not_to be_empty
      expect(db_service.library_database_service_response.last.name).to eq('Kōbunsō Taika Koshomoku')
    end

    it 'builds a working more_link' do
      expect(db_service.more_link.to_s).to eq('https://libguides.princeton.edu/az.php?q=Kobunso%20Taika%20Koshomoku')
    end
  end
end
