# frozen_string_literal: true

class RackServiceController
  # rescue_from StandardError, with: :show_standard_error
  # rescue_from Timeout::Error, Errno::ECONNRESET, Net::ProtocolError, with: :show_http_error
  # rescue_from AllsearchError, with: :show_allsearch_error
  # rescue_from ActionController::ParameterMissing, with: :show_query_error
  # rescue_from URI::InvalidURIError, with: :rescue_from_error
  # rescue_from ArgumentError, with: :rescue_from_error
  attr_reader :query

  # def show
  #   @query = service.new(query_terms: query_params)

  #   render json: query.our_response
  # end

  private

  attr_reader :service

  def query_params
    params.require(:query).gsub(/[#{Regexp.escape(special_characters)}]/, ' ')
          .gsub(/\s+/, ' ')
          .strip
  end

  def show_standard_error(exception)
    Honeybadger.notify exception
    render_error(problem: 'APPLICATION_ERROR',
                 message: "This application threw #{exception.class}",
                 status: :internal_server_error)
  end

  # :reek:FeatureEnvy
  def show_http_error(exception)
    Honeybadger.notify exception
    render_error(problem: 'UPSTREAM_ERROR',
                 message: "Query to upstream failed with #{exception.class}, message: #{exception.message}",
                 status: :internal_server_error)
  end

  # :reek:FeatureEnvy
  def show_allsearch_error(exception)
    Honeybadger.notify exception
    render_error(problem: exception.problem,
                 message: exception.message,
                 status: :internal_server_error)
  end

  def show_query_error
    # We don't report these to Honeybadger, since the system is working as
    # expected in these cases by telling the user they need to enter a query.
    render_error(problem: 'QUERY_IS_EMPTY',
                 message: 'The query param must contain non-whitespace characters.',
                 status: :bad_request)
  end

  def rescue_from_error
    @query = service.new(query_terms: URI.encode_uri_component(query_params))

    render json: query.our_response
  end

  def render_error(problem:, message:, status:)
    render json: { error: {
      problem:,
      message:
    } }, status:
  end

  def special_characters
    '{}#!</>'
  end
end
