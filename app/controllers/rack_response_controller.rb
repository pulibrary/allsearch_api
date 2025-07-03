# frozen_string_literal: true

class RackResponseController
  def self.call(env)
    request = Rack::Request.new(env)
    new(request).response
  end

  def initialize(request)
    @request = request
  end

  def response
    if empty_query?
      empty_query_response
    else
      data_response
    end
  end

  ErrorResponse = Struct.new(:problem, :message, :status) do
    def respond
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

  attr_reader :request, :service

  # :reek:TooManyStatements
  def data_response
    [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [json]]
  rescue AllsearchError => error
    allsearch_error_response error
  rescue Timeout::Error, Errno::ECONNRESET, Net::ProtocolError => error
    upstream_http_error_response error
  rescue StandardError => error
    standard_error_response error
  end

  def json
    service.new(query_terms:).our_response
  end

  def empty_query?
    query_terms == ''
  end

  def query_terms
    @query_terms ||= case request.params['query']
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

  # :reek:UtilityFunction
  def allsearch_error_response(exception)
    Honeybadger.notify exception
    ErrorResponse.new(exception.problem,
                      exception.message,
                      500).respond
  end

  # :reek:UtilityFunction
  def upstream_http_error_response(exception)
    Honeybadger.notify exception
    ErrorResponse.new('UPSTREAM_ERROR',
                      "Query to upstream failed with #{exception.class}, message: #{exception.message}",
                      500).respond
  end

  # :reek:UtilityFunction
  def standard_error_response(exception)
    Honeybadger.notify exception
    ErrorResponse.new('APPLICATION_ERROR',
                      "This application threw #{exception.class}",
                      500).respond
  end

  def special_characters
    '{}#!</>'
  end
end
