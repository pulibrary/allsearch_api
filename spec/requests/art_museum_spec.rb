# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/artmuseum' do
  it 'returns json' do
    get '/search/artmuseum?query=cats'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    let(:expected_response) do
      { number: 263,
        more: 'https://artmuseum.princeton.edu/search/collections?mainSearch=%22cats%22',
        records: [
          { title: 'Two cats',
            creator: 'Theophile-Alexandre Steinlen, 1859–1923; born Lausanne, Switzerland; died Paris, France',
            id: '6463',
            type: 'artobjects',
            url: 'https://artmuseum.princeton.edu/collections/objects/6463',
            other_fields: {
              credit_line: 'Bequest of Dan Fellows Platt, Class of 1895',
              medium: 'Graphite',
              dimensions: '25.1 × 26.2 cm. (9 7/8 × 10 5/16 in.)',
              primary_image: 'https://puam-loris.aws.princeton.edu/loris/INV34694.jp2',
              object_number: 'x1948-1210'
            } }
        ] }
    end

    it 'can take a parameter' do
      get '/search/artmuseum?query=cats'

      expect(response).to be_successful
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body.keys).to contain_exactly(:number, :more, :records)
      expect(response_body[:number]).to eq(expected_response[:number])
      expect(response_body[:records].first.keys).to contain_exactly(:title, :creator, :id, :type, :url,
                                                                    :other_fields)
      expect(response_body[:records].first).to match(expected_response[:records].first)
    end

    it 'only returns the first three records' do
      get '/search/artmuseum?query=cats'

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:records].size).to eq(3)
    end
  end
end
