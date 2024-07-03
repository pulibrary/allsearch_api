# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rails::HTML5::SafeListSanitizer do
  context 'with a custom scrubber' do
    let(:sanitizer) { sanitizer = described_class.new }

    it 'removes anchor tags' do
      test_string = '<a>This is a test</a>'
      expected = 'This is a test'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'removes script tags' do
      test_string = '<script src="example.com"></script><p>This is a test</p>'
      expected = '<p>This is a test</p>'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'removes link tags' do
      test_string = '<link rel="example.com"><p>This is a test</p>'
      expected = '<p>This is a test</p>'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'does not remove allowed tags' do
      test_string = '<b><i>This is a test</i></b>'
      expected = '<b><i>This is a test</i></b>'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end

    it 'does not remove header tags' do
      test_string = '<h1>This is a test</h1><h4>This is a smaller test</h4>'
      expected = '<h1>This is a test</h1><h4>This is a smaller test</h4>'

      expect(sanitizer.sanitize(test_string, scrubber: TextScrubber.new)).to eq(expected)
    end
  end
end
