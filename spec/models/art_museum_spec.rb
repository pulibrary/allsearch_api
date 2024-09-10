# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArtMuseum do
  it 'truncates very long queries before sending them to the art museum' do
    full_story = <<~END_FULL_STORY.gsub("\n", '')
      Call me Ishmael. Some years ago—never mind how long precisely—having little or no money
      in my purse, and nothing particular to interest me on shore, I thought I would sail about
      a little and see the watery part of the world. It is a way I have of driving off the spleen
      and regulating the circulation. Whenever I find myself growing grim about the mouth;
      whenever it is a damp, drizzly November in my soul; whenever I find myself involuntarily
      pausing before coffin warehouses, and bringing up the rear of every funeral I meet; and
      especially whenever my hypos get such an upper hand of me, that it requires a strong moral
      principle to prevent me from deliberately stepping into the street, and methodically knocking
      people’s hats off—then, I account it high time to get to sea as soon as I can.
    END_FULL_STORY
    truncated_story = URI.encode_uri_component <<~END_TRUNCATED_STORY.gsub("\n", '')
      Call me Ishmael. Some years ago—never mind how long precisely—having little or no money
      in my purse, and nothing particular to interest me on shore, I thought I would sail about
      a little and see the watery part of the
    END_TRUNCATED_STORY

    truncated_story_search = stub_request(:get, "https://data.artmuseum.princeton.edu/search?q=#{truncated_story}&size=3&type=all")
                             .to_return(status: 200, body: file_fixture('art_museum/cats.json'))

    described_class.new(query_terms: full_story)
    expect(truncated_story_search).to have_been_requested
  end
end
