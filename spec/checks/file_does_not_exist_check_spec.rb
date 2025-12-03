# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileDoesNotExistCheck do
  it 'returns success when the file does not exist' do
    result = described_class.new('some-random-file-1ehjfernfiuernfuinfkjwenfjsnjnfwe').call
    expect(result).to be_success
  end

  it 'returns failure when the file does exist' do
    result = described_class.new(__FILE__).call
    expect(result).to be_failure
  end
end
