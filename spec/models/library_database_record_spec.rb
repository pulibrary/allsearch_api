# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibraryDatabaseRecord do
  describe '::new_from_csv' do
    it 'generates a new database record from the CSV row' do
      csv_data = ['123', 'Academic Search', 'A very good database',
                  'Academic Search Plus; Academic Search Premier',
                  'http://ebsco.com',
                  'https://libguides.princeton.edu/resource/12345',
                  'Civil Engineering;Energy;Environment']
      described_class.new_from_csv(csv_data)
      record = described_class.last
      expect(record.libguides_id).to eq(123)
      expect(record.name).to eq('Academic Search')
      expect(record.description).to eq('A very good database')
      expect(record.alt_names).to contain_exactly('Academic Search Plus', 'Academic Search Premier')
      expect(record.url).to eq('http://ebsco.com')
      expect(record.friendly_url).to eq('https://libguides.princeton.edu/resource/12345')
      expect(record.subjects).to contain_exactly('Civil Engineering', 'Energy', 'Environment')
    end
  end

  describe 'query scope' do
    let(:doc1) do
      described_class.create(name: 'Resource',
                             alt_names_concat: 'EBSCO; JSTOR',
                             libguides_id: 1,
                             description: 'Great database',
                             subjects_concat: 'Electrical engineering;Computer science')
    end

    it 'finds exact matches in the description field' do
      expect(described_class.query('Great database')).to contain_exactly(doc1)
    end

    it 'finds case-insensitive matches in the description field' do
      expect(described_class.query('great database')).to contain_exactly(doc1)
    end

    it 'finds partial matches in the description field' do
      expect(described_class.query('great')).to contain_exactly(doc1)
    end

    it 'finds singular versions of plural search terms' do
      expect(described_class.query('databases')).to contain_exactly(doc1)
    end

    it 'finds exact matches in the subject_concat field' do
      expect(described_class.query('Computer science')).to contain_exactly(doc1)
    end

    it 'can negate searches with -' do
      expect(described_class.query('Computer -science')).to be_empty
    end

    it 'finds stemmed matches in the subject_concat field' do
      expect(described_class.query('computation')).to contain_exactly(doc1)
    end

    it 'finds matches in the title field' do
      expect(described_class.query('resource')).to contain_exactly(doc1)
    end

    it 'finds matches in the alt_names_concat field' do
      expect(described_class.query('jstor')).to contain_exactly(doc1)
    end

    context 'with fixture file loaded' do
      let(:libjobs_response) { file_fixture('libjobs/library-databases.csv') }

      before do
        stub_request(:get, 'https://lib-jobs.princeton.edu/library-databases.csv')
          .to_return(status: 200, body: libjobs_response)
        LibraryDatabaseLoadingService.new.run
      end

      it 'matches the sort from the original service' do
        pending('Waiting for more insight into LibGuides search')
        query_response = described_class.ordered_query('oxford music').with_pg_search_rank
        # The order from our current expected sort
        # expect(query_response[0].name).to eq('Oxford Music Online')
        # expect(query_response[0].pg_search_rank).to eq(0.99986285)
        # expect(query_response[1].name).to eq('Oxford Scholarship Online:  Music')
        # expect(query_response[1].pg_search_rank).to eq(0.9904934)
        # expect(query_response[2].name).to eq('Oxford Bibliographies: Music')
        # expect(query_response[2].pg_search_rank).to eq(0.985053)

        # The order from Libguides search https://libguides.princeton.edu/az.php?q=oxford%20music
        expect(query_response[0].name).to eq('Oxford Scholarship Online:  Music')
        expect(query_response[1].name).to eq('Oxford Bibliographies: Music')
        expect(query_response[2].name).to eq('Oxford Music Online')
      end
    end
  end
end
