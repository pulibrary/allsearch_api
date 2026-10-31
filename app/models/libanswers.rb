# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying Libanswers for FAQs
class Libanswers
  include Dry::Monads[:maybe]

  def our_response(query_terms:)
    service_response = service_response(query_terms:)['search']
    {
      number: service_response['numFound'],
      records: service_response['results'].map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link(query_terms:).value_or(nil)
    }.compact.to_json
  end

  def more_link(query_terms:)
    Some("https://faq.library.princeton.edu/search/?t=0&q=#{CGI.escape(query_terms).gsub(/\s+/, '+')}")
  end

  def service_response(query_terms:)
    uri(query_terms:)
      .then { libanswers_connection.get it, { 'Authorization' => "Bearer #{token}" } }
      .then do |response|
        if response.code == '200'
          JSON.parse(response.body)
        else
          { 'search' => { 'results' => [], 'numFound' => 0 } }
        end
      end
  end

  private

  # :reek:UtilityFunction
  def uri(query_terms:)
    URI.parse "https://faq.library.princeton.edu/api/1.1/search/#{CGI.escape(query_terms)}?iid=344&limit=3"
  end

  # This should not be memoized, since the token is refreshed regularly
  def token = token_cache.token

  def token_cache
    @token_cache ||= OAuthTokenCache.new(service: 'libanswers',
                                         endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token')
  end

  # :reek:FeatureEnvy
  def libanswers_connection
    @libanswers_connection ||= begin
      http = Net::HTTP.new('faq.library.princeton.edu', Net::HTTP.https_default_port)
      http.use_ssl = true
      http.start
    end
  end

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
  def document_class = LibanswersDocument
end
