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
end
