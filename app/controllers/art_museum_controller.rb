# frozen_string_literal: true

class ArtMuseumController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors
  def show
    @art_museum_query = ArtMuseum.new(query_terms: query_params)

    render json: @art_museum_query.our_response
  end

  private

  def query_params
    params.require(:query)
  end

  def show_query_errors(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
