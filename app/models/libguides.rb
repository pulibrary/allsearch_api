# frozen_string_literal: true

class Libguides
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
    "https://libguides.princeton.edu/srch.php?q=#{query_terms}"
  end

  def uri
    URI::HTTPS.build(host: 'lgapi-us.libapps.com',
                     path: '/1.2/guides',
                     query: query_hash)
  end

  def query_hash
    { search_terms: query_terms,
      sort_by: 'relevance',
      status: '1',
      expand: 'owner,subjects,tags' }.to_query
  end

  def request
    libguides_request = Net::HTTP::Get.new(uri)

    token = OAuthToken.find_or_create_by({ service: 'libguides',
                                           endpoint: 'https://lgapi-us.libapps.com/1.2/oauth/token' }).token
    libguides_request['Authorization'] = "Bearer #{token}"
    libguides_request
  end
end
