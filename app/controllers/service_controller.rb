# frozen_string_literal: true

class ServiceController < ApplicationController
  rescue_from AllsearchError, with: :show_allsearch_error
  rescue_from ActionController::ParameterMissing, with: :show_query_errors
  attr_reader :query

  def show
    @query = service.new(query_terms: query_params)

    render json: query.our_response
  end

  private

  attr_reader :service

  def query_params
    params.require(:query).gsub(/[#{Regexp.escape(special_characters)}]/, ' ')
          .gsub(/\s+/, ' ')
          .strip
  end

  # :reek:FeatureEnvy
  def show_allsearch_error(exception)
    render json: { error: {
      problem: exception.problem,
      message: exception.message
    } }, status: :internal_server_error
  end

  def show_query_errors
    render json: { error: {
      problem: 'QUERY_IS_EMPTY',
      message: 'The query param must contain non-whitespace characters.'
    } }, status: :bad_request
  end

  def special_characters
    '{}#!</>'
  end
end
