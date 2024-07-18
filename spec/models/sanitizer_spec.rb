# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sanitizer do
  context 'with a custom scrubber' do
    let(:sanitizer) { described_class.new }

    it 'removes anchor tags' do
      test_string = '<a>This is a test</a>'
      expected = 'This is a test'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'removes script tags' do
      test_string = '<script src="example.com"></script><p>This is a test</p>'
      expected = 'This is a test'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'removes link tags' do
      test_string = '<link rel="example.com">This is a test'
      expected = 'This is a test'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'does not remove allowed tags' do
      test_string = '<b><i>This is a test</i></b>'
      expected = '<b> <i>This is a test</i></b>'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'removes header tags' do
      test_string = '<h1>This is a test</h1><h4>This is a smaller test</h4>'
      expected = 'This is a test This is a smaller test'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'repeats the & character verbatim' do
      test_string = 'Cataloging & Classification Quarterly'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(test_string)
    end
  end
end
