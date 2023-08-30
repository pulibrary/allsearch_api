# frozen_string_literal: true

module Blacklight
  extend ActiveSupport::Concern

  def blacklight_service_response(query_terms:, service:)
    uri = URI::HTTPS.build(host: "#{service}.princeton.edu", path: '/catalog.json',
                           query: "q=#{query_terms}&search_field=all_fields&per_page=3")
    response = Net::HTTP.get(uri)
    JSON.parse(response, symbolize_names: true)
  end

  def id(document:)
    document[:id]
  end

  def url(document:)
    # All documents should have a url, so it's ok to raise an error if it's not present
    document[:links][:self]
  end

  def documents
    @documents ||= service_response[:data]
  end

  def number
    service_response[:meta][:pages][:total_count]
  end

  def more_link
    URI::HTTPS.build(host: "#{service}.princeton.edu", path: '/catalog',
                     query: "q=#{query_terms}&search_field=all_fields")
  end
end
