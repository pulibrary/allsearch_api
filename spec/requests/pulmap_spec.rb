# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/pulmap' do
  it 'returns json' do
    stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulmap/select?facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&q=scribner&rows=3&sort=score%20desc')
      .to_return(status: 200, body: file_fixture('solr/pulmap/scribner.json'))
    get '/search/pulmap?query=scribner'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    before do
      stub_request(:get, 'http://lib-solr8-prod.princeton.edu:8983/solr/pulmap/select?facet=false&fl=layer_slug_s,dc_title_s,dc_creator_sm,dc_publisher_s,dc_format_s,dc_description_s,dc_rights_s,layer_geom_type_s&q=scribner&rows=3&sort=score%20desc')
        .to_return(status: 200, body: file_fixture('solr/pulmap/scribner.json'))
    end

    # rubocop:disable Layout/LineLength
    let(:expected_response) do
      { number: 16,
        more: 'https://maps.princeton.edu/catalog?q=scribner&search_field=all_fields',
        records: [
          { title: 'South America : wall-atlas',
            creator: 'Guyot, A. (Arnold), 1807-1884',
            description: "\"Card series.\" Relief shown by hachures and form lines. \"Entered according to Act of Congress in the year 1865 by Charles Scribner & Co. ...\" Inset: Profiles from west to east. Wall map. Scribner, Armstrong, & Co. flourished ca. 1871-1879. cf. Tooley's dictionary of mapmakers.",
            publisher: 'New York : Published by Scribner, Armstrong & Co. ... [between 1871 and 1879].',
            id: 'princeton-6682x6396',
            type: 'TIFF',
            url: 'https://maps.princeton.edu/catalog/princeton-6682x6396',
            other_fields: {
              layer_geom_type: 'Image',
              rights: 'Public'
            } }
        ] }
    end
    # rubocop:enable Layout/LineLength

    it 'can take a parameter' do
      get '/search/pulmap?query=scribner'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body.keys).to contain_exactly(:number, :more, :records)
      expect(response_body[:number]).to eq(expected_response[:number])
      expect(response_body[:records].second.keys).to contain_exactly(:title, :creator, :description,
                                                                     :publisher, :id,
                                                                     :type, :url,
                                                                     :other_fields)

      expect(response_body[:records].second).to match(expected_response[:records].first)
    end

    it 'only returns the first three records' do
      get '/search/pulmap?query=scribner'

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:records].size).to eq(3)
    end
  end

  context 'without a search term' do
    it 'returns a 400 bad request' do
      get '/search/pulmap?query='

      expect(response).to be_bad_request
    end
  end
end
