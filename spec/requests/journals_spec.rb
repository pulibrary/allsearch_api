# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/rack_solr_shared_examples'

RSpec.describe 'GET /search/journals' do
  let(:response_body) { JSON.parse(response.body, symbolize_names: true) }
  let(:solr_base_url) { %r{http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production} }
  let(:service_path) { 'journals' }

  before do
    stub_request(:get, %r{http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production})
      .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
  end

  it_behaves_like 'a rack solr controller'

  context 'when service returns a Net::HTTP exception' do
    before do
      allow(Journals).to receive(:new).and_raise(Net::HTTPFatalError.new('Some info', ''))
      allow(Honeybadger).to receive(:notify)
    end

    it 'handles Net::HTTP exceptions' do
      get '/search/journals?query=123'
      expect(response).to have_http_status(:internal_server_error)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq({
                                   problem: 'UPSTREAM_ERROR',
                                   message: 'Query to upstream failed with Net::HTTPFatalError, message: Some info'
                                 })
      expect(Honeybadger).to have_received(:notify)
    end
  end

  it 'returns json' do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=berry+basket&fq=format:Journal&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
      .to_return(status: 200, body: file_fixture('solr/catalog/berry_basket.json'))
    get '/search/journals?query=berry+basket'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=berry+basket&fq=format:Journal&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
        .to_return(status: 200, body: file_fixture('solr/catalog/berry_basket.json'))
    end

    let(:expected_response) do
      { number: 1,
        more: 'https://catalog.princeton.edu/catalog?q=berry+basket&f[format][]=Journal&search_field=all_fields',
        records: [
          { title: 'Berry basket : newsletter for Missouri small fruit and vegetable growers',
            id: '99125520326606421',
            type: 'Journal',
            url: 'https://catalog.princeton.edu/catalog/99125520326606421',
            other_fields: {
              online_access_count: '1',
              resource_url: 'https://na05.alma.exlibrisgroup.com/view/uresolver/01PRI_INST/openurl?u.ignore_date_coverage=true&portfolio_pid=53933585090006421&Force_direct=true',
              resource_url_label: 'CRL Open Access Serials'
            } }
        ] }
    end

    it 'can take a parameter' do
      get '/search/journals?query=berry+basket'

      expect(response).to be_successful

      expect(response_body.keys).to contain_exactly(:number, :more, :records)
      expect(response_body[:records].first.keys).to contain_exactly(:title, :id, :type, :url,
                                                                    :other_fields)
      expect(response_body[:records].first).to match(expected_response[:records].first)
      expect(response_body[:records].second).to match(expected_response[:records].second)
    end
  end

  context 'without a search term' do
    it 'returns a 400 bad request' do
      get '/search/journals?query='

      expect(response).to be_bad_request
    end
  end

  context 'with an electronic resource' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=berry+basket&fq=format:Journal&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
        .to_return(status: 200, body: file_fixture('solr/catalog/berry_basket.json'))
    end

    it 'includes the resource_url in other_fields' do
      get '/search/journals?query=berry+basket'

      expect(response).to be_successful
      expect(response_body[:records].first[:other_fields][:resource_url]).to eq('https://na05.alma.exlibrisgroup.com/view/uresolver/01PRI_INST/openurl?u.ignore_date_coverage=true&portfolio_pid=53933585090006421&Force_direct=true')
    end

    it 'includes the resource_url_label in other_fields' do
      get '/search/journals?query=berry+basket'

      expect(response).to be_successful
      expect(response_body[:records].first[:other_fields][:resource_url_label])
        .to eq('CRL Open Access Serials')
    end
  end
end
