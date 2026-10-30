# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for querying Libanswers for FAQs
class Libanswers
  attr_reader :query_terms

  include Dry::Monads[:maybe]

  def initialize(query_terms:)
    @query_terms = CGI.escape(query_terms)
  end

  def our_response
    hash = {
      number:,
      records: documents.map { |document| document_class.new(document:, doc_keys:).to_h }
    }
    hash[:more] = more_link.value_or(nil)
    hash.compact.to_json
  end

  def number
    service_response['search']['numFound']
  end

  def more_link
    Some("https://faq.library.princeton.edu/search/?t=0&q=#{query_terms.gsub(/\s+/, '+')}")
  end

  def documents
    service_response['search']['results']
  end

  def service_response
    @service_response ||= Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      response = http.request(request)
      if response.code == '200'
        JSON.parse(response.body)
      else
        { 'search' => { 'results' => [], 'numFound' => 0 } }
      end
    end
  end

  private

  def uri
    URI.parse "https://faq.library.princeton.edu/api/1.1/search/#{query_terms}?iid=344&limit=3"
  end

  def request
    libanswers_request = Net::HTTP::Get.new(uri)

    token = OAuthTokenCache.new(service: 'libanswers',
                                endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token').token
    libanswers_request['Authorization'] = "Bearer #{token}"
    libanswers_request
  end

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
  def document_class = LibanswersDocument
end
