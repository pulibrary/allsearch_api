# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LibanswersDocument do
  describe '#url' do
    context 'when libanswers gives us a URL with escaped slashes' do
      let(:document) do
        { 'url' => 'https:\/\/faq.library.princeton.edu\/econ\/faq\/11210' }
      end

      it 'removes the escaping' do
        doc = described_class.new(document:, doc_keys: [])
        expect(doc.url).to eq('https://faq.library.princeton.edu/econ/faq/11210')
      end
    end
  end
end
