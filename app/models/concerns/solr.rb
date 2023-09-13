# frozen_string_literal: true

module Solr
  def solr_service_response(query_terms:)
    query = "q=#{query_terms}&rows=3&facet=false&fl=#{solr_fields}&sort=#{solr_sort}"
    query = "#{query}&#{extra_solr_params}" if respond_to? :extra_solr_params
    uri = URI::HTTPS.build(host: 'lib-solr8-prod.princeton.edu', port: '8983',
                           path: "/solr/#{solr_collection}/select",
                           query:)
    response = Net::HTTP.get(uri)
    JSON.parse(response, symbolize_names: true)
  end

  def id(document:)
    document[:id]
  end

  def number
    service_response[:response][:numFound]
  end

  def more_link
    URI::HTTPS.build(host: "#{service}.princeton.edu", path: '/catalog',
                     query: "q=#{query_terms}&search_field=all_fields")
  end

  def documents
    @documents ||= service_response[:response][:docs]
  end

  def url(document:)
    "https://#{service}.princeton.edu/catalog/#{id(document:)}"
  end
end
