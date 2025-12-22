# frozen_string_literal: true

require 'dry-monads'

class Libguides
  include Dry::Monads[:maybe]
  include Parsed

  attr_reader :query_terms

  def initialize(query_terms:)
    @query_terms = query_terms
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

  def more_link
    Some("https://libguides.princeton.edu/srch.php?q=#{query_terms}")
  end

  def uri
    QueryUri.new(
      host: 'lgapi-us.libapps.com',
      path: '/1.2/guides',
      user_query: query_terms,
      query_builder: ->(query_terms) { "expand=owner,subjects,tags&search_terms=#{query_terms}&sort_by=relevance&status=1" }
    ).call
  end

  def request
    libguides_request = Net::HTTP::Get.new(uri)

    token = OAuthTokenCache.new(service: 'libguides',
                                endpoint: 'https://lgapi-us.libapps.com/1.2/oauth/token').token
    libguides_request['Authorization'] = "Bearer #{token}"
    libguides_request
  end
end
