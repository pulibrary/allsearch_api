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

  describe 'with a token already in the database' do
    before do
      OAuthToken.create!({ service: 'libanswers',
                           endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token' })
      stub_libanswers(query: 'printer', fixture: 'libanswers/printer.json')
    end

    it 'does not try to insert duplicate OAuthTokens into the database' do
      expect do
        service = described_class.new(query_terms: 'printer')
        service.service_response
      end.not_to change(OAuthToken, :count)
    end
  end
end
