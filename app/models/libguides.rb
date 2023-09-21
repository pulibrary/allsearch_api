# frozen_string_literal: true

class Libguides
  include Parsed

  def initialize(query_terms:)
    @query_terms = query_terms
  end

  def documents
    service_response[0..2]
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

  attr_reader :query_terms

  def more_link
    "https://libguides.princeton.edu/srch.php?q=#{query_terms}"
  end

  def uri
    URI.parse "https://lgapi-us.libapps.com/1.2/guides?search_terms=#{CGI.escape(query_terms)}&sort_by=relevance&status=1&expand=owner%2Csubjects%2Ctags"
  end

  def request
    libguides_request = Net::HTTP::Get.new(uri)

    token = OAuthToken.create_or_find_by({ service: 'libguides',
                                           endpoint: 'https://lgapi-us.libapps.com/1.2/oauth/token' }).token
    libguides_request['Authorization'] = "Bearer #{token}"
    libguides_request
  end
end
