# frozen_string_literal: true

require 'spec_helper'

RSpec.describe QueryUri do
  it 'escapes & in the user query' do
    uri = described_class.new(
      host: 'example.org',
      user_query: 'anime & manga',
      query_builder: ->(query_terms) { "q=#{query_terms}" }
    ).call
    expect(uri.to_s).to eq 'https://example.org?q=anime+%26+manga'
  end
end
