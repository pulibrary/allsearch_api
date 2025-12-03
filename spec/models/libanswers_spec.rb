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
      RepositoryFactory.oauth_token.create(service: 'libanswers',
                                           endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token')
      stub_libanswers(query: 'printer', fixture: 'libanswers/printer.json')
    end

    it 'does not try to insert duplicate OAuthTokens into the database' do
      expect do
        service = described_class.new(query_terms: 'printer')
        service.service_response
      end.not_to(change { Rails.application.config.rom.relations[:oauth_tokens].count })
    end
  end

  context 'when the upstream service returns a 400' do
    before do
      RepositoryFactory.oauth_token.create(service: 'libanswers',
                                           endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token')
      stub_libanswers(query: 'printer', fixture: 'libanswers/printer.json')
      stub_request(:post, 'https://faq.library.princeton.edu/api/1.1/oauth/token')
        .with(body: 'client_id=ABC&client_secret=12345&grant_type=client_credentials')
        .to_return(status: 200, body: file_fixture('libanswers/oauth_token.json'))
      stub_request(:get, 'https://faq.library.princeton.edu/api/1.1/search/0%25000?iid=344&limit=3')
        .with(
          headers: {
            'Authorization' => 'Bearer abcdef1234567890abcdef1234567890abcdef12'
          }
        )
        .to_return(status: 400, body: 'NGINX error')
    end

    it 'has an empty documents array' do
      service = described_class.new(query_terms: '0%000')
      expect(service.documents).to be_empty
    end

    it 'has 0 as the number' do
      service = described_class.new(query_terms: '0%000')
      expect(service.number).to eq 0
    end
  end
end
