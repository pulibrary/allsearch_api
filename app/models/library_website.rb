# frozen_string_literal: true

class LibraryWebsite
  include Parsed

  attr_reader :query_terms

  def initialize(query_terms:)
    @query_terms = query_terms
  end

  def documents
    service_response['content'][0..2]
  end

  def number
    service_response['content'].count
  end

  def service_response
    response = Net::HTTP.post_form(uri, 'search' => query_terms)
    @service_response ||= JSON.parse(response.body)
  end

  private

  def more_link
    "https://#{website_config[:host]}/search?keys=#{query_terms}"
  end

  def uri
    URI::HTTPS.build(host: website_config[:host],
                     path: website_config[:path])
  end

  def website_config
    Rails.application.config_for(:allsearch)[:library_website]
  end
end
