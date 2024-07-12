# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TextScrubber do
  it 'removes <h3> tags' do
    original = Nokogiri::HTML5::DocumentFragment.parse('Here is my heading: <h3>HELLO!</h3>')
    expect(Loofah.scrub_fragment(original, described_class.new).to_s).to eq('Here is my heading: HELLO!')
  end

  it 'removes <p> tags' do
    original = Nokogiri::HTML5::DocumentFragment.parse('Here is my p: <p>HELLO!</p>')
    expect(Loofah.scrub_fragment(original, described_class.new).to_s).to eq('Here is my p: HELLO!')
  end

  it 'keeps <em> tags' do
    original = Nokogiri::HTML5::DocumentFragment.parse('Here is my em: <em>HELLO!</em>')
    expect(Loofah.scrub_fragment(original, described_class.new).to_s).to eq('Here is my em: <em>HELLO!</em>')
  end

  it 'keeps <b> tags' do
    original = Nokogiri::HTML5::DocumentFragment.parse('Here is my b: <b>HELLO!</b>')
    expect(Loofah.scrub_fragment(original, described_class.new).to_s).to eq('Here is my b: <b>HELLO!</b>')
  end

  it 'keeps <i> tags' do
    original = Nokogiri::HTML5::DocumentFragment.parse('Here is my i: <i>HELLO!</i>')
    expect(Loofah.scrub_fragment(original, described_class.new).to_s).to eq('Here is my i: <i>HELLO!</i>')
  end

  it 'keeps <strong> tags' do
    original = Nokogiri::HTML5::DocumentFragment.parse('Here is my strong: <strong>HELLO!</strong>')
    expect(Loofah.scrub_fragment(original,
                                 described_class.new).to_s).to eq('Here is my strong: <strong>HELLO!</strong>')
  end
end
