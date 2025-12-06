# frozen_string_literal: true

require 'dry-monads'
require_relative '../../environment'

# This module helps classes communicate with Solr APIs
module Solr
  include Dry::Monads[:maybe]

  def solr_service_response
    response = Net::HTTP.get_response(solr_uri)
    response_code = response.code.to_i
    if response_code > 399
      raise AllsearchError.new(problem: 'UPSTREAM_ERROR',
                               msg: "Solr returned a #{response_code} for " \
                                    "path #{solr_uri.path} on host #{solr_uri.host}")
    end
    JSON.parse(response.body, symbolize_names: true)
  end

  def number
    service_response[:response][:numFound]
  end

  def more_link
    Some(URI::HTTPS.build(host: "#{service_subdomain}.princeton.edu", path: '/catalog',
                          query: "q=#{query_terms}&search_field=all_fields"))
  end

  def documents
    @documents ||= service_response[:response][:docs]
  end

  private

  # :reek:ManualDispatch
  def solr_uri
    @solr_uri ||= begin
      query = "q=#{@query_terms}&rows=3&facet=false&fl=#{solr_fields.join(',')}&sort=#{solr_sort}"
      query = "#{query}&#{extra_solr_params}" if respond_to? :extra_solr_params
      URI::HTTP.build(host: solr_config[:host],
                      port: solr_config[:port],
                      path: "/solr/#{solr_collection}/select",
                      query:)
    end
  end

  def solr_collection
    allsearch_config[service.to_sym][:solr][:collection]
  end

  def solr_config
    allsearch_config[service.to_sym][:solr]
  end

  def service_subdomain
    allsearch_config[service.to_sym][:subdomain]
  end
end
