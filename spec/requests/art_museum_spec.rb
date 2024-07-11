# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/artmuseum' do
  it 'returns json' do
    stub_art_museum(query: 'cats', fixture: 'art_museum/cats.json')
    get '/search/artmuseum?query=cats'

    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  context 'with a search term' do
    before do
      stub_art_museum(query: 'cats', fixture: 'art_museum/cats.json')
    end

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
              object_number: 'x1948-1210',
              date: '1900'
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

  context 'when the art museum is temporarily down' do
    before do
      stub_art_museum(query: 'cats', fixture: 'art_museum/nginx_503')
    end

    it 'returns a 500 and specifies UPSTREAM_ERROR in the response' do
      get '/search/artmuseum?query=cats'
      expect(response).to have_http_status :internal_server_error
      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body[:error]).to eq({
                                            problem: 'UPSTREAM_ERROR',
                                            message: "Query to upstream failed with \n" \
                                                     "503 Service Temporarily Unavailable\n\n" \
                                                     "503 Service Temporarily Unavailable\nnginx/1.24.0\n\n\n"
                                          })
    end
  end
end
