# frozen_string_literal: true

require 'net/http'

# A client for querying solr
class SolrClient
  # :reek:ControlParameter
  def initialize(solr_config:, query_builder:, logger: ALLSEARCH_LOGGER, connection: nil)
    @solr_config = solr_config
    @logger = logger
    @query_builder = query_builder
    @connection = connection || new_connection
  end

  # :reek:TooManyStatements
  def query(query_terms:)
    request_uri = new_request_uri(query_terms:)

    fetch(request_uri)
      .then { handle_response_by_code(it, request_uri) }
      .then { JSON.parse(it, symbolize_names: true) }
  rescue Timeout::Error, SystemCallError, Net::ProtoServerError, Net::ProtoFatalError => error
    handle_connection_error(error)
  end

  private

  attr_reader :connection, :logger, :query_builder, :solr_config

  def new_request_uri(query_terms:)
    query_uri.call(
      uri_class: URI::HTTP,
      host: solr_config[:host],
      port: solr_config[:port],
      path: "/solr/#{solr_config[:collection]}/select",
      user_query: query_terms,
      query_builder:
    )
  end

  def fetch(request_uri)
    connection.get(request_uri.request_uri)
  end

  def new_connection
    Net::HTTP.new(solr_config[:host], solr_config[:port])
  end

  def handle_response_by_code(response, request_uri)
    return response.body if response.code.to_i < 400

    raise AllsearchError.new(problem: 'UPSTREAM_ERROR', msg: upstream_error_message(response, request_uri))
  end

  def handle_connection_error(error)
    logger.error('Solr error', error)
    raise AllsearchError.new(problem: 'UPSTREAM_ERROR', msg: "Solr request raised #{error}")
  end

  # :reek:FeatureEnvy
  def upstream_error_message(response, request_uri)
    "Solr returned a #{response.code.to_i} for path #{request_uri.path} on host " \
      "#{request_uri.host} with response body: #{response.body.to_s[0, max_error_body_length]}"
  end

  def max_error_body_length = 10_000

  def query_uri = @query_uri ||= QueryUri.new
end
