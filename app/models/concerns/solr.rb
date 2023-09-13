# frozen_string_literal: true

# This module helps classes communicate with Solr APIs
module Solr
  # :reek:ManualDispatch
  def solr_service_response(query_terms:)
    query = "q=#{query_terms}&rows=3&facet=false&fl=#{solr_fields.join(',')}&sort=#{solr_sort}"
    query = "#{query}&#{extra_solr_params}" if respond_to? :extra_solr_params
    uri = url_builder.build(host: solr_config[:host],
                            port: solr_config[:port],
                            path: "/solr/#{solr_collection}/select",
                            query:)
    response = Net::HTTP.get(uri)
    JSON.parse(response, symbolize_names: true)
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

  private

  def url_builder
    solr_config[:ssl] ? URI::HTTPS : URI::HTTP
  end

  def solr_collection
    Rails.application.config_for(:allsearch)[service][:solr][:collection]
  end

  def solr_config
    Rails.application.config_for(:allsearch)[service][:solr]
  end
end
