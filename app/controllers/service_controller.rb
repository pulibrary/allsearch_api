# frozen_string_literal: true

class ServiceController < ApplicationController
  def show
    @query = service.new(query_terms: query_params)

    render json: query.our_response
  end

  private

  attr_reader :query, :service

  def query_params
    params.require(:query)
  end

  def show_query_errors(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
