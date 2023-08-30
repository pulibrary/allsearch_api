# frozen_string_literal: true

class CatalogController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors
  def show
    # @query = query_params
    @catalog_query = Catalog.new(query_terms: query_params)

    render json: @catalog_query.our_response
  end

  private

  def query_params
    params.require(:query)
  end

  def show_query_errors(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
