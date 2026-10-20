# frozen_string_literal: true

# This class is responsible for taking incoming HTTP requests for
# search paths, validating them, and then passing them along to
# its service.

# :reek:DataClump
class SearchController
  def initialize(service:, honeybadger: Honeybadger)
    @service = service
    @honeybadger = honeybadger
  end

  def call(env)
    request = Rack::Request.new(env)
    if empty_query?(request)
      empty_query_response
    else
      data_response(request)
    end
  end

  ErrorResponse = Data.define(:problem, :message, :status) do
    def respond
      ALLSEARCH_LOGGER.error('Error', to_h)
      [
        status,
        { 'Content-Type' => 'application/json; charset=utf-8' },
        [{ error: {
          problem:,
          message:
        } }.to_json]
      ]
    end
  end

  private

  attr_reader :service, :honeybadger

  # :reek:TooManyStatements
  def data_response(request)
    [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [json(request)]]
  rescue AllsearchError => error
    allsearch_error_response error, request
  rescue Timeout::Error, Errno::ECONNRESET, Net::ProtocolError => error
    upstream_http_error_response error, request
  rescue StandardError => error
    standard_error_response error, request
  end

  def json(request)
    service.new(query_terms: query_terms(request)).our_response
  end

  def empty_query?(request)
    query_terms(request) == ''
  end

  def query_terms(request)
    case request.params['query']
    # If the query contains any non-whitespace characters
    in /\S/ => query
      query.gsub(/[#{Regexp.escape(special_characters)}]/, ' ')
           .gsub(/\s+/, ' ')
           .strip
    else
      ''
    end
  end

  # :reek:UtilityFunction
  def empty_query_response
    ErrorResponse.new('QUERY_IS_EMPTY',
                      'The query param must contain non-whitespace characters.',
                      400).respond
  end

  # :reek:UtilityFunction, :reek:FeatureEnvy
  def allsearch_error_response(exception, request)
    honeybadger.notify exception, url: request.url
    ErrorResponse.new(exception.problem,
                      exception.message,
                      500).respond
  end

  # :reek:UtilityFunction, :reek:FeatureEnvy
  def upstream_http_error_response(exception, request)
    honeybadger.notify exception, url: request.url
    ErrorResponse.new('UPSTREAM_ERROR',
                      "Query to upstream failed with #{exception.class}, message: #{exception.message}",
                      500).respond
  end

  # :reek:UtilityFunction
  def standard_error_response(exception, request)
    honeybadger.notify exception, url: request.url
    ErrorResponse.new('APPLICATION_ERROR',
                      "This application threw #{exception.class}",
                      500).respond
  end

  def special_characters
    '{}#!</>'
  end
end
