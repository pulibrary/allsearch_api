# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying the Art Museum API
class ArtMuseum
  include Parsed
  include Dry::Monads[:maybe]

  attr_reader :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'artmuseum'
    @service_response = art_museum_service_response
  end

  def query_terms
    if query_is_too_long?
      @query_terms[0, query_end]
    else
      @query_terms
    end
  end

  private

  def art_museum_service_response
    uri = URI::HTTPS.build(host: 'data.artmuseum.princeton.edu', path: '/search',
                           query: "q=#{query_terms}&type=all&size=3")
    response = Net::HTTP.get(uri)
    begin
      JSON.parse(response, symbolize_names: true)
    rescue JSON::ParserError
      handle_parser_error response
    end
  end

  def number
    service_response.dig(:hits, :total)
  end

  def more_link
    Some(URI::HTTPS.build(host: 'artmuseum.princeton.edu', path: '/search/collections',
                          query: "mainSearch=\"#{query_terms}\""))
  end

  def documents
    @documents ||= service_response.dig(:hits, :hits)
  end

  def handle_parser_error(response)
    raise AllsearchError.new(
      problem: 'UPSTREAM_ERROR',
      msg: "Query to upstream failed with #{strip_html_tags(response)}"
    )
  end

  def strip_html_tags(text)
    text.gsub(/<[^>]*>/, '')
  end

  def query_is_too_long?
    @query_terms.length > maximum_characters
  end

  def query_end
    # The index of the last whitespace character within maximum_characters
    @query_terms.rindex(/\s/, maximum_characters)
  end

  def maximum_characters
    220
  end
end
