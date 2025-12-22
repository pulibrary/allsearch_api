# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sentence do
  it 'returns empty string for nil' do
    expect(described_class.new(nil).call).to eq ''
  end

  it 'returns empty string for empty array' do
    expect(described_class.new([]).call).to eq ''
  end

  it 'returns a simple string for 1-element array' do
    expect(described_class.new(['dog']).call).to eq 'dog'
  end

  it 'joins the last element with and' do
    expect(described_class.new(%w[dog cat]).call).to eq 'dog and cat'
  end

  it 'joins elements with ,' do
    expect(described_class.new(%w[dog cat whale]).call).to eq 'dog, cat, and whale'
  end

  it 'can handle many elements' do
    expect(described_class.new(%w[dog cat whale dolphin salmon giraffe]).call).to eq(
      'dog, cat, whale, dolphin, salmon, and giraffe'
    )
  end
end
