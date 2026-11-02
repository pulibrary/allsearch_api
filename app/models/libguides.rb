# frozen_string_literal: true

require 'dry-monads'

class Libguides
  include Dry::Monads[:maybe]

  LIBGUIDES_HOSTNAME = 'lgapi-us.libapps.com'

  def our_response(query_terms:)
    service_response = service_response(query_terms:)
    {
      number: service_response.count,
      records: (service_response[0..2] || []).map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link(query_terms:).value_or(nil)
    }.compact.to_json
  end

  def service_response(query_terms:)
    uri(query_terms:)
      .then { libguides_connection.get(it, { 'Authorization' => "Bearer #{token}" }) }
      .then { JSON.parse(it.body) }
  end

  private

  def document_class = LibguidesDocument
  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]

  def more_link(query_terms:)
    Some("https://libguides.princeton.edu/srch.php?q=#{query_terms}")
  end

  def uri(query_terms:)
    query_uri.call(
      host: LIBGUIDES_HOSTNAME,
      path: '/1.2/guides',
      user_query: query_terms,
      query_builder: lambda { |query_terms|
        "expand=owner,subjects,tags&search_terms=#{query_terms}&sort_by=relevance&status=1"
      }
    )
  end

  def query_uri = @query_uri ||= QueryUri.new

  # This should not be memoized, since the token is refreshed regularly
  def token = token_cache.token

  def token_cache
    @token_cache ||= OAuthTokenCache.new(service: 'libguides',
                                         endpoint: 'https://lgapi-us.libapps.com/1.2/oauth/token')
  end

  # :reek:FeatureEnvy
  def libguides_connection
    @libguides_connection ||= begin
      http = Net::HTTP.new(LIBGUIDES_HOSTNAME, Net::HTTP.https_default_port)
      http.use_ssl = true
      http.start
    end
  end
end
