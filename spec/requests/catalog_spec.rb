# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/rack_solr_shared_examples'

RSpec.describe 'GET /search/catalog' do
  let(:response_body) { JSON.parse(response.body, symbolize_names: true) }
  let(:solr_base_url) { %r{http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production} }
  let(:service_path) { 'catalog' }

  it 'returns json' do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=rubix&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
      .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
    get '/search/catalog?query=rubix'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=rubix&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
        .to_return(status: 200, body: file_fixture('solr/catalog/rubix.json'))
    end

    let(:expected_response) do
      { number: 7,
        more: 'https://catalog.princeton.edu/catalog?q=rubix&search_field=all_fields',
        records: [
          { title: "Rub'ix qatinamit = El canto del pueblo : Estudiantina del Instituto Indígena de Santiago " \
                   '/ [Oscar Azmitia, Manuel Salazar].',
            creator: 'Azmitia, Oscar',
            publisher: '[Guatemala] : El Instituto, [199-]',
            id: 'SCSB-11568989',
            type: 'Book',
            url: 'https://catalog.princeton.edu/catalog/SCSB-11568989',
            other_fields: {
              online_access_count: '0',
              first_barcode: 'HNG4XF',
              first_call_number: 'ML421.I55 A96 1990z',
              first_library: 'ReCAP'
            } },
          { title: 'COVID-19 and minority health access : illustrating symptomatic cases ' \
                   'from reported minority communities and healthcare gaps due to COVID-19.',
            publisher: '[Lawrence, Mass.] : Rubix Life Sciences, 2020.',
            id: '99122566163506421',
            type: 'Book',
            url: 'https://catalog.princeton.edu/catalog/99122566163506421',
            other_fields: { online_access_count: '0' } }
        ] }
    end

    it 'can take a parameter' do
      get '/search/catalog?query=rubix'

      expect(response).to be_successful

      expect(response_body.keys).to contain_exactly(:number, :more, :records)
      expect(response_body[:records].first.keys).to contain_exactly(:title, :creator, :publisher, :id, :type, :url,
                                                                    :other_fields)
      expect(response_body[:records].first).to match(expected_response[:records].first)
      expect(response_body[:records].second).to match(expected_response[:records].second)
    end

    it 'only returns the first three records' do
      get '/search/catalog?query=rubix'

      expect(response_body[:records].size).to eq(3)
    end
  end

  context 'without a search term' do
    it 'returns a 400 bad request' do
      get '/search/catalog?query='

      expect(response).to be_bad_request
    end
  end

  context 'without a publisher in records' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=pangulubalang&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
        .to_return(status: 200, body: file_fixture('solr/catalog/pangulubalang.json'))
    end

    it 'does not raise the error NoMethodError' do
      get '/search/catalog?query=pangulubalang'

      expect(response).to be_successful
    end

    it 'does not include unused keys' do
      get '/search/catalog?query=pangulubalang'

      expect(response_body[:records].first.keys).to contain_exactly(:title, :id, :type, :url, :other_fields)
    end
  end

  context 'with weird search strings' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=What%20if%20%22I%20quote%22%20my%20search?&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
        .to_return(status: 200, body: file_fixture('solr/catalog/what_if.json'))
    end

    it 'appropriately escapes the query' do
      get '/search/catalog?query=What if "I quote" my search?'

      expect(response).to be_successful
      expect(response_body[:records]).to be_empty
      expect(response_body[:more]).to eq('https://catalog.princeton.edu/catalog?q=What%20if%20%22I%20quote%22%20my%20search?&search_field=all_fields')
    end
  end

  context 'with CJK characters' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=%E8%A7%A6%E7%89%A9%E7%94%9F%E6%83%85%E8%AF%9D%E9%81%93%E5%8D%97&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
        .to_return(status: 200, body: file_fixture('solr/catalog/触物生情话道南.json'))
    end

    it 'matches the catalog search results' do
      # 触物生情话道南 is escaped after you put it in the browser - in the search bar it still shows as the
      # correct characters
      get '/search/catalog?query=%E8%A7%A6%E7%89%A9%E7%94%9F%E6%83%85%E8%AF%9D%E9%81%93%E5%8D%97'

      expect(response).to be_successful
      expect(response_body[:number]).to be(81)
    end
  end

  context 'with an electronic resource' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=Didgeridoo%20Mania&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
        .to_return(status: 200, body: file_fixture('solr/catalog/didgeridoo_mania.json'))
    end

    it 'includes the resource_url in other_fields' do
      get '/search/catalog?query=Didgeridoo+Mania'

      expect(response).to be_successful
      expect(response_body[:records].first[:other_fields][:resource_url]).to eq('https://na05.alma.exlibrisgroup.com/view/uresolver/01PRI_INST/openurl?u.ignore_date_coverage=true&portfolio_pid=53763462940006421&Force_direct=true')
    end

    it 'includes the resource_url_label in other_fields' do
      get '/search/catalog?query=Didgeridoo+Mania'

      expect(response).to be_successful
      expect(response_body[:records].first[:other_fields][:resource_url_label])
        .to eq('Music Online: Contemporary World Music - All Titles')
    end
  end

  context 'when search results include coins' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/catalog-alma-production/select?facet=false&fl=id,title_display,author_display,pub_created_display,format,holdings_1display,electronic_portfolio_s,electronic_access_1display&q=coin%20762&rows=3&sort=score%20desc,%20pub_date_start_sort%20desc,%20title_sort%20asc')
        .to_return(status: 200, body: file_fixture('solr/catalog/coin-762.json'))
    end

    it 'includes a status of On-site access' do
      get '/search/catalog?query=coin+762'

      expect(response).to be_successful
      expect(response_body[:records].first[:other_fields][:first_status]).to eq('On-site access')
    end
  end

  it_behaves_like 'a rack solr controller'

  context 'when service returns a Net::HTTP exception' do
    before do
      allow(Catalog).to receive(:new).and_raise(Net::HTTPFatalError.new('Some info', ''))
      allow(Honeybadger).to receive(:notify)
    end

    it 'handles Net::HTTP exceptions' do
      get '/search/catalog?query=123'
      expect(response).to have_http_status(:internal_server_error)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq({
                                   problem: 'UPSTREAM_ERROR',
                                   message: 'Query to upstream failed with Net::HTTPFatalError, message: Some info'
                                 })
      expect(Honeybadger).to have_received(:notify)
    end
  end

  context 'when our logic returns some kind of Standard exception' do
    before do
      allow(Catalog).to receive(:new).and_raise(KeyError.new('this key does not exist'))
      allow(Honeybadger).to receive(:notify)
    end

    it 'handles the exception' do
      get '/search/catalog?query=123'
      expect(response).to have_http_status(:internal_server_error)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:error]).to eq({
                                   problem: 'APPLICATION_ERROR',
                                   message: 'This application threw KeyError'
                                 })
      expect(Honeybadger).to have_received(:notify)
    end
  end
end
