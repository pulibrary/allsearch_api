# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryDatabase do
  let(:query_terms) { 'foo' }
  let(:db_service) { described_class.new(query_terms:) }

  it 'has the correct more_link' do
    expect(db_service.more_link.value!.to_s).to eq('https://libguides.princeton.edu/az/databases?q=foo')
  end

  context 'with accents in the query terms' do
    # URL escaped version of Kōbunsō Taika Koshomoku
    let(:query_terms) { 'K%C5%8Dbuns%C5%8D%20Taika%20Koshomoku' }

    let(:libjobs_response) { file_fixture('libjobs/library-databases.csv') }

    before do
      stub_request(:get, 'https://lib-jobs.princeton.edu/library-databases.csv')
        .to_return(status: 200, body: libjobs_response)
      LibraryDatabaseLoadingService.new.run
    end

    it 'can search for queries as passed by the controller' do
      our_response = JSON.parse(db_service.our_response, symbolize_names: true)
      expect(our_response[:records]).not_to be_empty
      expect(our_response[:records].last[:title]).to eq('Kōbunsō Taika Koshomoku')
    end

    it 'builds a working more_link' do
      expect(db_service.more_link.value!.to_s).to eq('https://libguides.princeton.edu/az/databases?q=Kobunso%20Taika%20Koshomoku')
    end

    context 'when the diacritics are decomposed into two separate characters' do
      let(:query_terms) { 'Ko%CC%84bunso%CC%84%20Taika%20Koshomoku' }

      it 'builds a working more_link' do
        expect(db_service.more_link.value!.to_s).to eq('https://libguides.princeton.edu/az/databases?q=Kobunso%20Taika%20Koshomoku')
      end
    end

    context 'with glottal stops in the query terms' do
      # URL escaped version of Maʻagarim
      let(:query_terms) { 'Ma%CA%BBagarim' }

      it 'can search for queries as passed by the controller' do
        our_response = JSON.parse(db_service.our_response, symbolize_names: true)
        expect(our_response[:records]).not_to be_empty
      end
    end
  end
end
