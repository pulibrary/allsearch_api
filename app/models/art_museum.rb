# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying the Art Museum API
class ArtMuseum
  include Dry::Monads[:maybe]

  def initialize(query_terms:)
    @query_terms = query_terms
  end

  def our_response
    query = clean_query

    art_museum_response(query)
      .then { parse_response(it, query) }
      .to_json
  end

  private

  def document_class = ArtMuseumDocument

  def clean_query
    tokens[..(maximum_tokens - 1)].join(' ')
  end

  def art_museum_response(query)
    response = Net::HTTP.get(uri(query))
    begin
      JSON.parse(response, symbolize_names: true)
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
      host: 'data.artmuseum.princeton.edu',
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
      msg: "Query to upstream failed with #{strip_html_tags(response)}"
    )
  end

  # :reek:UtilityFunction
  def strip_html_tags(text) = text.gsub(/<[^>]*>/, '')

  def tokens = Tokenizer.tokenize(@query_terms)
  def maximum_tokens = 40

  def query_uri = @query_uri ||= QueryUri.new
  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
end
