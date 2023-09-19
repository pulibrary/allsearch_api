# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Libanswers do
  describe '#more_link' do
    it 'incorporates the query term into libanswers search url' do
      libanswers = described_class.new(query_terms: 'ducks')
      expect(libanswers.more_link).to eq('https://faq.library.princeton.edu/search/?t=0&q=ducks')
    end

    it 'puts + between words' do
      libanswers = described_class.new(query_terms: 'root beer')
      expect(libanswers.more_link).to eq('https://faq.library.princeton.edu/search/?t=0&q=root+beer')
    end
  end
end
