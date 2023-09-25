# frozen_string_literal: true

require 'rails_helper'

describe 'CORS' do
  let(:headers) { ['localhost:3000', 'http://example.com', 'https://example.edu'] }

  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/dpul-production/select?facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,readonly_format_ssim,readonly_collections_tesim&q=cats&rows=3&sort=score%20desc')
      .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
  end

  context 'when request comes from http://localhost:3000' do
    let(:header) { 'http://localhost:3000' }

    it 'reflects the origin as the Access-Control-Allow-Origin, ' \
       'telling the browser that requests are allowed' do
      get '/search/dpul?query=cats', headers: { HTTP_ORIGIN: header }
      expect(response.headers['Access-Control-Allow-Origin']).to eq(header)
    end
  end

  context 'when request comes from https://allsearch.princeton.edu' do
    let(:header) { 'https://allsearch.princeton.edu' }

    it 'reflects the origin as the Access-Control-Allow-Origin, ' \
       'telling the browser that requests are allowed' do
      get '/search/dpul?query=cats', headers: { HTTP_ORIGIN: header }
      expect(response.headers['Access-Control-Allow-Origin']).to eq(header)
    end
  end

  context 'when request comes from https://allsearch-staging.princeton.edu' do
    let(:header) { 'https://allsearch-staging.princeton.edu' }

    it 'reflects the origin as the Access-Control-Allow-Origin, ' \
       'telling the browser that requests are allowed' do
      get '/search/dpul?query=cats', headers: { HTTP_ORIGIN: header }
      expect(response.headers['Access-Control-Allow-Origin']).to eq(header)
    end
  end

  context 'when request comes from https://some-random-site.gov' do
    let(:header) { 'https://some-random-site.gov' }

    it 'returns no Access-Control-Allow-Origin header' do
      get '/search/dpul?query=cats', headers: { HTTP_ORIGIN: header }
      expect(response.headers).not_to have_key('Access-Control-Allow-Origin')
    end
  end

  context 'when request comes from https://allsearch.princeton.edu.bad.website.com' do
    let(:header) { 'https://allsearch.princeton.edu.bad.website.com' }

    it 'returns no Access-Control-Allow-Origin header' do
      get '/search/dpul?query=cats', headers: { HTTP_ORIGIN: header }
      expect(response.headers).not_to have_key('Access-Control-Allow-Origin')
    end
  end
end
