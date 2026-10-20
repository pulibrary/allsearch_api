# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tokenizer do
  it 'tokenizes on whitespace' do
    tokenized = described_class.tokenize('hello world')
    expect(tokenized).to eq %w[hello world]
  end

  it 'tokenizes on punctuation' do
    tokenized = described_class.tokenize('high-spirited')
    expect(tokenized).to eq %w[high spirited]
  end
end
