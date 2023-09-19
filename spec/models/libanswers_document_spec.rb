# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibanswersDocument do
  describe '#url' do
    context 'when libanswers gives us a URL with escaped slashes' do
      let(:json) do
        { 'url' => 'https:\/\/faq.library.princeton.edu\/econ\/faq\/11210' }
      end

      it 'removes the escaping' do
        document = described_class.new(json:, doc_keys: [])
        expect(document.url).to eq('https://faq.library.princeton.edu/econ/faq/11210')
      end
    end
  end
end
