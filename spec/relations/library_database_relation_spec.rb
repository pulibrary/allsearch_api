# frozen_string_literal: true

require 'rack_helper'

# rubocop:disable RSpec/NestedGroups
RSpec.describe LibraryDatabaseRelation do
  let(:library_databases) { ALLSEARCH_ROM.relations[:library_database_records] }

  describe '#query' do
    before do
      repo = RepositoryFactory.library_database
      repo.create(name: 'Resource',
                  alt_names_concat: 'EBSCO; JSTOR',
                  libguides_id: 1,
                  description: 'Great database',
                  subjects_concat: 'Electrical engineering;Computer science')
    end

    let(:doc1) { library_databases.where(libguides_id: 1).first }

    it 'finds exact matches in the description field' do
      expect(library_databases.query('Great database').pluck(:id)).to contain_exactly(doc1.id)
    end

    it 'finds case-insensitive matches in the description field' do
      expect(library_databases.query('great database').pluck(:id)).to contain_exactly(doc1.id)
    end

    it 'finds partial matches in the description field' do
      expect(library_databases.query('great').pluck(:id)).to contain_exactly(doc1.id)
    end

    it 'finds singular versions of plural search terms' do
      expect(library_databases.query('databases').pluck(:id)).to contain_exactly(doc1.id)
    end

    it 'finds exact matches in the subject_concat field' do
      expect(library_databases.query('Computer science').pluck(:id)).to contain_exactly(doc1.id)
    end

    it 'can negate searches with -' do
      expect(library_databases.query('Computer -science').to_a).to be_empty
    end

    it 'finds stemmed matches in the subject_concat field' do
      expect(library_databases.query('computation').pluck(:id)).to contain_exactly(doc1.id)
    end

    it 'finds matches in the title field' do
      expect(library_databases.query('resource').pluck(:id)).to contain_exactly(doc1.id)
    end

    it 'finds matches in the alt_names_concat field' do
      expect(library_databases.query('jstor').pluck(:id)).to contain_exactly(doc1.id)
    end

    context 'with fixture file loaded' do
      before do
        stub_request(:get, 'https://lib-jobs.princeton.edu/library-databases.csv')
          .to_return(status: 200, body: file_fixture('libjobs/library-databases.csv'))
        LibraryDatabaseLoadingService.new.run
      end

      it 'matches the current expected search' do
        query_response = library_databases.query('oxford music').to_a
        expect(query_response[0].name).to eq('Oxford Music Online')
        expect(query_response[1].name).to eq('Oxford Scholarship Online:  Music')
        expect(query_response[2].name).to eq('Oxford Bibliographies: Music')
      end

      it 'is safe from sql injection' do
        bad_string = "'))); DROP TABLE library_database_records;"
        expect do
          library_databases.query(bad_string)
        end.not_to(change(library_databases, :count))
      end

      context 'with Japanese text using differently composed characters' do
        let(:precomposed) { 'Kōbunsō Taika Koshomoku' }
        let(:no_accents) { 'Kobunso Taika Koshomoku' }
        let(:decomposed) { 'Kōbunsō Taika Koshomoku' }

        it 'finds the title regardless of composition' do
          result1 = library_databases.query(precomposed)
          expect(result1.count).to eq(1)
          result2 = library_databases.query(no_accents)
          expect(result2.count).to eq(1)
          result3 = library_databases.query(decomposed)
          expect(result3.count).to eq(1)
        end
      end

      context 'with a glottal stop character' do
        let(:query_terms) { 'Maʻagarim' }

        it 'finds the database' do
          result1 = library_databases.query(query_terms)
          expect { library_databases.query(query_terms) }.not_to raise_error
          expect(result1.count).to eq(1)
        end
      end
    end
  end
end
# rubocop:enable RSpec/NestedGroups
