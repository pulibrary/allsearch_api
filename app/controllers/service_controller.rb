# frozen_string_literal: true

class ServiceController < ApplicationController
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

  def show_query_errors(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def special_characters
    '{}#!</>'
  end
end
