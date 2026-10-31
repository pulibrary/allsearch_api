# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying the Art Museum API
class ArtMuseum
  include Dry::Monads[:maybe]

  ART_MUSEUM_API_HOST = 'data.artmuseum.princeton.edu'

  def our_response(query_terms:)
    query = clean_query(query_terms:)
    art_museum_response(query)
      .then { parse_response(it, query) }
      .to_json
  end

  private

  def document_class = ArtMuseumDocument

  def clean_query(query_terms:)
    tokens(query_terms:)[..(maximum_tokens - 1)].join(' ')
  end

  def art_museum_response(query)
    response = artmuseum_connection.get(uri(query))
    begin
      JSON.parse(response.body, symbolize_names: true)
    rescue JSON::ParserError
      handle_parser_error response
    end
  end

  def parse_response(raw, query)
    {
      number: raw.dig(:hits, :total),
      records: raw.dig(:hits, :hits).map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link(query)
    }.compact
  end

  def uri(query)
    query_uri.call(
      host: ART_MUSEUM_API_HOST,
      path: '/search',
      user_query: query,
      query_builder: ->(query_terms) { "q=#{query_terms}&type=all&size=3" }
    )
  end

  def more_link(query)
    query_uri.call(
      host: 'artmuseum.princeton.edu',
      path: '/search/collections',
      user_query: query,
      query_builder: ->(query_terms) { "mainSearch=\"#{query_terms}\"" }
    )
  end

  def handle_parser_error(response)
    raise AllsearchError.new(
      problem: 'UPSTREAM_ERROR',
      msg: "Query to upstream failed with #{strip_html_tags(response.body)}"
    )
  end

  # :reek:FeatureEnvy
  def artmuseum_connection
    @artmuseum_connection ||= begin
      http = Net::HTTP.new(ART_MUSEUM_API_HOST, Net::HTTP.https_default_port)
      http.use_ssl = true
      http.start
    end
  end

  # :reek:UtilityFunction
  def strip_html_tags(text) = text.gsub(/<[^>]*>/, '')

  # :reek:UtilityFunction
  def tokens(query_terms:) = Tokenizer.tokenize(query_terms)
  def maximum_tokens = 40

  def query_uri = @query_uri ||= QueryUri.new
  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
end
