# frozen_string_literal: true

require 'rails_helper'

describe 'CORS' do
  before do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/dpul-production/select?facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,readonly_format_ssim,readonly_collections_tesim&group=true&group.facet=true&group.field=content_metadata_iiif_manifest_field_ssi&group.limit=1&group.main=true&q=cats&rows=3&sort=score%20desc')
      .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
  end

  context 'when request comes from http://localhost:3000' do
    it 'reflects the origin as the Access-Control-Allow-Origin, ' \
       'telling the browser that requests are allowed' do
      header 'Origin', 'http://localhost:3000'
      get '/search/dpul?query=cats'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('http://localhost:3000')
    end
  end

  context 'when request comes from http://localhost:5173' do
    it 'reflects the origin as the Access-Control-Allow-Origin, ' \
       'telling the browser that requests are allowed' do
      header 'Origin', 'http://localhost:5173'
      get '/search/dpul?query=cats'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('http://localhost:5173')
    end
  end

  context 'when request comes from https://allsearch.princeton.edu' do
    it 'reflects the origin as the Access-Control-Allow-Origin, ' \
       'telling the browser that requests are allowed' do
      header 'Origin', 'https://allsearch.princeton.edu'
      get '/search/dpul?query=cats'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('https://allsearch.princeton.edu')
    end
  end

  context 'when request comes from https://allsearch-staging.princeton.edu' do
    it 'reflects the origin as the Access-Control-Allow-Origin, ' \
       'telling the browser that requests are allowed' do
      header 'Origin', 'https://allsearch-staging.princeton.edu'
      get '/search/dpul?query=cats'
      expect(last_response.headers['Access-Control-Allow-Origin']).to eq('https://allsearch-staging.princeton.edu')
    end
  end

  context 'when request comes from https://some-random-site.gov' do
    it 'returns no Access-Control-Allow-Origin header' do
      header 'Origin', 'https://some-random-site.gov'
      get '/search/dpul?query=cats'
      expect(last_response.headers).not_to have_key('Access-Control-Allow-Origin')
    end
  end

  context 'when request comes from https://allsearch.princeton.edu.bad.website.com' do
    it 'returns no Access-Control-Allow-Origin header' do
      header 'Origin', 'https://allsearch.princeton.edu.bad.website.com'
      get '/search/dpul?query=cats'
      expect(last_response.headers).not_to have_key('Access-Control-Allow-Origin')
    end
  end
end
