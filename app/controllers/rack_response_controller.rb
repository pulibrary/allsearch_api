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
      [200, { 'Content-Type' => 'application/json; charset=utf-8' }, [json]]
    end
  end

  private

  attr_reader :request

  def json
    raise 'Subclass should implement #json'
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
    # We don't report these to Honeybadger, since the system is working as
    # expected in these cases by telling the user they need to enter a query.
    error_response(problem: 'QUERY_IS_EMPTY',
                   message: 'The query param must contain non-whitespace characters.',
                   status: 400)
  end

  # :reek:UtilityFunction
  def error_response(problem:, message:, status:)
    [
      status,
      { 'Content-Type' => 'application/json; charset=utf-8' },
      [{ error: {
        problem:,
        message:
      } }.to_json]
    ]
  end

  def special_characters
    '{}#!</>'
  end
end
