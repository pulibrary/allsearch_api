# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solr do
  describe '#status_uris' do
    let(:expected_solr8_uri) do
      URI::HTTP.build(host: 'lib-solr8-prod.princeton.edu',
                      port: '8983',
                      path: '/solr/admin/cores',
                      query: 'action=STATUS')
    end

    it 'has an array of status uris' do
      expect(described_class.status_uris).to contain_exactly(expected_solr8_uri)
    end
  end
end
