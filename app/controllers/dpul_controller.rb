# frozen_string_literal: true

class DpulController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors
  def show
    @dpul_query = Dpul.new(query_terms: query_params)

    render json: dpul_query.our_response
  end

  private

  def query_params
    params.require(:query)
  end

  def show_query_errors(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  attr_reader :dpul_query
end
