# frozen_string_literal: true

# This class is responsible for querying Libanswers for FAQs
class Libanswers
  attr_reader :query_terms

  include Parsed
  def initialize(query_terms:)
    @query_terms = CGI.escape(query_terms)
  end

  def number
    service_response['search']['numFound']
  end

  def more_link
    "https://faq.library.princeton.edu/search/?t=0&q=#{query_terms.gsub(/\s+/, '+')}"
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

    token = OAuthToken.find_or_create_by({ service: 'libanswers',
                                           endpoint: 'https://faq.library.princeton.edu/api/1.1/oauth/token' }).token
    libanswers_request['Authorization'] = "Bearer #{token}"
    libanswers_request
  end
end
