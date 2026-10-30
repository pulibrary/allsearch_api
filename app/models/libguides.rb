# frozen_string_literal: true

require 'dry-monads'

class Libguides
  include Dry::Monads[:maybe]

  attr_reader :query_terms

  def initialize(query_terms:)
    @query_terms = query_terms
  end

  def our_response
    {
      number:,
      records: documents.map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link.value_or(nil)
    }.compact.to_json
  end

  def documents
    service_response[0..2] || []
  end

  def number
    service_response.count
  end

  def service_response
    @service_response ||= Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      response = http.request(request)
      JSON.parse(response.body)
    end
  end

  private

  def document_class = LibguidesDocument
  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]

  def more_link
    Some("https://libguides.princeton.edu/srch.php?q=#{query_terms}")
  end

  def uri
    QueryUri.new.call(
      host: 'lgapi-us.libapps.com',
      path: '/1.2/guides',
      user_query: query_terms,
      query_builder: lambda { |query_terms|
        "expand=owner,subjects,tags&search_terms=#{query_terms}&sort_by=relevance&status=1"
      }
    )
  end

  def request
    libguides_request = Net::HTTP::Get.new(uri)

    token = OAuthTokenCache.new(service: 'libguides',
                                endpoint: 'https://lgapi-us.libapps.com/1.2/oauth/token').token
    libguides_request['Authorization'] = "Bearer #{token}"
    libguides_request
  end
end
