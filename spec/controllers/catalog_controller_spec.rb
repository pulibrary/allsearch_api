# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/service_controller_shared_examples'

RSpec.describe CatalogController do
  before do
    stub_request(:get, %r{http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production})
      .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
  end

  it_behaves_like 'a service controller'

  context 'when service returns a Net::HTTP exception' do
    before do
      allow(Catalog).to receive(:new).and_raise(Net::HTTPFatalError.new('Some info', ''))
      allow(Honeybadger).to receive(:notify)
    end

    it 'handles Net::HTTP exceptions' do
      get :show, params: { query: '123' }
      expect(response).to have_http_status(:internal_server_error)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq({
                                   problem: 'UPSTREAM_ERROR',
                                   message: 'Query to upstream failed with Net::HTTPFatalError, message: Some info'
                                 })
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
