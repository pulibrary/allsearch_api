# frozen_string_literal: true

require 'rack_helper'

RSpec.describe SampleDataCreationService do
  describe '#create' do
    before do
      stub_request(:get, 'http://localhost:7872/solr/catalog-qa/select?facet=false&fl=*&q=cats&rows=5')
        .to_return(status: 200, body: file_fixture('solr/catalog/cats_all_fields.json'))
    end

    after do
      test_file = allsearch_path('sample-data/test.json')
      test_file.delete if test_file.file?
    end

    it 'downloads sample data from staging' do
      creator = described_class.new(solr_collection: 'catalog-qa',
                                    query: 'cats',
                                    filename: 'test.json')
      creator.create
      created_data = JSON.parse(allsearch_path('sample-data/test.json').read)
      expect(created_data.count).to eq(3)
      expect(created_data.first.keys).not_to include('hashed_id_ssi')
      expect(created_data.first.keys).not_to include('_version_')
      expect(created_data.first.keys).not_to include('timestamp')
    end
  end
end
