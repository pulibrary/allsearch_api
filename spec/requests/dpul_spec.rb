# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/dpul' do
  it 'returns json' do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/dpul-production/select?facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,readonly_format_ssim,readonly_collections_tesim&group=true&group.facet=true&group.field=content_metadata_iiif_manifest_field_ssi&group.limit=1&group.main=true&q=cats&rows=3&sort=score%20desc')
      .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
    get '/search/dpul?query=cats'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/dpul-production/select?facet=false&fl=id,readonly_title_ssim,readonly_creator_ssim,readonly_publisher_ssim,readonly_format_ssim,readonly_collections_tesim&group=true&group.facet=true&group.field=content_metadata_iiif_manifest_field_ssi&group.limit=1&group.main=true&q=cats&rows=3&sort=score%20desc')
        .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
    end

    let(:expected_response) do
      { number: 238,
        more: 'https://dpul.princeton.edu/catalog?q=cats&search_field=all_fields',
        records: [
          { title: 'Robinson Crusoe, The clever cats, &c. : a picture-book for the nursery ' \
                   '; containing sixteen coloured illustrations',
            creator: 'Defoe, Daniel, 1661?-1731',
            publisher: 'London ; Edinburgh ; New York : Thomas Nelson & Sons, [not after 1888]',
            id: '02578b4e2ccf4497f1426a3ab7e11464',
            type: 'Book',
            url: 'https://dpul.princeton.edu/catalog/02578b4e2ccf4497f1426a3ab7e11464',
            other_fields: {
              collection: 'Lloyd E. Cotsen'
            } }
        ] }
    end

    it 'can take a parameter' do
      get '/search/dpul?query=cats'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body.keys).to contain_exactly(:number, :more, :records)
      expect(response_body[:number]).to eq(expected_response[:number])
      expect(response_body[:records].first.keys).to contain_exactly(:title, :publisher, :id, :type, :url,
                                                                    :other_fields)
      expect(response_body[:records].second.keys).to contain_exactly(:title, :creator, :publisher, :id, :type, :url,
                                                                     :other_fields)
      expect(response_body[:records].second).to match(expected_response[:records].first)
    end

    it 'only returns the first three records' do
      get '/search/dpul?query=cats'

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:records].size).to eq(3)
    end
  end

  context 'without a search term' do
    it 'returns a 400 bad request' do
      get '/search/dpul?query='

      expect(response).to be_bad_request
    end
  end

  context 'with unexpected characters' do
    let(:bad_script) { '{bad#!/bin/bash<script>}' }
    let(:simplified_chinese_cat) { '读' }
    let(:redundant_spaces) { "war   and\tpeace" }
    let(:percent_sign) { '%25' }
    let(:query_terms) do
      [
        bad_script,
        simplified_chinese_cat,
        redundant_spaces,
        percent_sign
      ]
    end

    before do
      stub_request(:get, %r{http://lib-solr8-prod.princeton.edu:8983/solr/dpul-production})
        .to_return(status: 200, body: file_fixture('solr/dpul/cats.json'))
    end

    it 'sanitizes input' do
      get "/search/dpul?query=#{CGI.escape bad_script}"

      expect(response).to have_http_status(:ok)
      expect(WebMock).to have_requested(:get, /bad%20bin%20bash%20script/)
    end

    it 'removes redundant space from query' do
      get "/search/dpul?query=#{CGI.escape redundant_spaces}"

      expect(response).to have_http_status(:ok)
      expect(WebMock).to have_requested(:get, /war%20and%20peace/)
    end

    it 'does not throw an error when the url contains numbers and the percent sign' do
      get "/search/dpul?query=#{CGI.escape percent_sign}"

      expect(response).to have_http_status(:ok)
      expect(WebMock).to have_requested(:get, /%25/)
    end

    it 'does not raise an error' do
      expect do
        query_terms.each do |term|
          get "/search/dpul?query=#{CGI.escape term}"
        end
      end.not_to raise_exception
    end
  end

  context 'with Japanese text using differently composed characters' do
    let(:precomposed) { 'Kōbunsō Taika Koshomoku' }
    let(:no_accents) { 'Kobunso Taika Koshomoku' }
    let(:decomposed) { 'Kōbunsō Taika Koshomoku' }
    let(:query_terms) do
      [
        precomposed,
        no_accents,
        decomposed
      ]
    end

    it 'does not raise an error' do
      expect do
        query_terms.each do |term|
          get "/search/dpul?query=#{CGI.escape term}"
        end
      end.not_to raise_exception
    end
  end
end
