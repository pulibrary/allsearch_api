# frozen_string_literal: true

require 'dry-monads'
require 'net/http'

# This module helps classes communicate with Solr APIs
module Solr
  include Dry::Monads[:maybe]

  def solr_service_response
    raw_solr_response.then do |response|
      response_code = response.code.to_i
      raise upstream_error(msg: upstream_error_message(response)) if response_code > 399

      JSON.parse(raw_solr_response.body, symbolize_names: true)
    end
  end

  def number
    service_response[:response][:numFound]
  end

  def more_link
    Some(QueryUri.new(
      host: "#{service_subdomain}.princeton.edu",
      path: '/catalog',
      user_query: @query_terms,
      query_builder: ->(query_terms) { "q=#{query_terms}&search_field=all_fields" }
    ).call)
  end

  def documents
    @documents ||= service_response[:response][:docs]
  end

  private

  def raw_solr_response
    @raw_solr_response ||= begin
      Net::HTTP.get_response(solr_uri)
    rescue Timeout::Error, SystemCallError, Net::ProtoServerError, Net::ProtoFatalError => error
      ALLSEARCH_LOGGER.error('Solr error', error)
      raise upstream_error(msg: "Solr request raised #{error}")
    end
  end

  # :reek:ManualDispatch
  def solr_uri
    @solr_uri ||= QueryUri.new(
      uri_class: URI::HTTP,
      host: solr_config[:host],
      port: solr_config[:port],
      path: "/solr/#{solr_collection}/select",
      user_query: @query_terms,
      query_builder: search_query_builder
    ).call
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

  def search_query_builder
    lambda do |query_terms|
      query = "q=#{query_terms}&rows=3&facet=false&fl=#{solr_fields.join(',')}&sort=#{solr_sort}"
      query = "#{query}&#{extra_solr_params}" if extra_solr_params
      query
    end
  end

  def extra_solr_params; end

  # :reek:UtilityFunction
  def upstream_error_message(response)
    "Solr returned a #{response.code.to_i} for path #{solr_uri.path} on host " \
      "#{solr_uri.host} with response body: #{response.body.to_s[0, max_error_body_length]}"
  end

  def max_error_body_length = 10_000

  # :reek:UtilityFunction
  def upstream_error(msg:) = AllsearchError.new(problem: 'UPSTREAM_ERROR', msg:)
end
