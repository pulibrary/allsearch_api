# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /search/article' do
  before do
    stub_summon(query: 'forest', fixture: 'article/forest.json')
    get '/search/article?query=forest'
  end

  it 'returns json' do
    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end

  it 'only contains string values in the other_fields' do
    expected_other_fields = {
      'publication_date' => '2009',
      'publication_year' => '2009',
      'start_page' => 'xviii',
      'end_page' => 'xviii',
      'fulltext_available' => 'Full-text available',
      'abstract' => "In 1994, the Government of Cameroon\nintroduced an array of forest policy reforms, both\n" \
                    "regulatory and market-based, to support a more organized,\ntransparent, and sustainable system " \
                    "for accessing and using\nforest resources. This report describes how these reforms\nplayed out " \
                    "in the rainforests of Cameroon. The intention is\nto provide a brief account of a complex " \
                    "process and identify\nwhat worked, what did not, and what can be improved. The\nbarriers to " \
                    "placing Cameroon's forests at the service\nof its people, its economy, and the environment " \
                    "originated\nwith the extractive policies of successive colonial\nadministrations. The barriers " \
                    "were further consolidated\nafter independence through a system of political patronage\nand " \
                    "influence in which forest resources became a coveted\ncurrency for political support. These " \
                    "deeply entangled\ncommercial and political interests have only recently, and\nreluctantly, " \
                    "started to diverge. In 1994, the government\nintroduced an array of forest policy reforms, " \
                    "both\nregulatory and market based. The reforms changed the rules\ndetermining who could gain " \
                    "access to forest resources, how\naccess could be obtained, how those resources could be " \
                    "used,\nand who will benefit from their use. This report assesses\nthe outcomes of reforms in " \
                    "forest-rich areas of Cameroon,\nwhere the influence of industrial and political elites " \
                    "has\ndominated since colonial times.",
      'isxn' => '9780821378786'
    }
    expect(response.parsed_body['records'].first['other_fields']).to eq expected_other_fields
  end
end
