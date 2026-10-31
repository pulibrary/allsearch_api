# frozen_string_literal: true

require 'dry-monads'
require 'flipper'

class LibraryWebsite
  include Dry::Monads[:maybe]

  def initialize
    # The website config is a reusable dependency, so we capture it on the instance.
    @website_config = ALLSEARCH_CONFIGS[:allsearch][:library_website]
  end

  def our_response(query_terms:)
    results = service_response(query_terms:)['content']
    {
      number: results.count,
      records: results[0..2].map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link(query_terms:).value_or(nil)
    }.compact.to_json
  end

  def self.library_website_host = LibraryWebsite.website_config[:host]

  def self.website_config = ALLSEARCH_CONFIGS[:allsearch][:library_website]

  def service_response(query_terms:)
    response = Net::HTTP.post_form(uri, 'search' => query_terms)
    response_code = response.code
    if response_code.start_with? '5'
      raise AllsearchError.new(msg: "The library website API returned a #{response_code} HTTP status code.")
    end

    JSON.parse(response.body)
  end

  private

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
  def document_class = LibraryWebsiteDocument

  def more_link(query_terms:)
    Some(query_uri.call(
           host: LibraryWebsite.library_website_host,
           path: '/search',
           query_builder: ->(query_terms) { "keys=#{query_terms}" },
           user_query: query_terms
         ))
  end

  def query_uri = @query_uri ||= QueryUri.new

  def uri
    URI::HTTPS.build(host: LibraryWebsite.library_website_host,
                     path: @website_config[:path])
  end
end
