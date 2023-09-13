# frozen_string_literal: true

class FindingaidsController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors
  def show
    @findingaids_query = Findingaids.new(query_terms: query_params)

    render json: findingaids_query.our_response
  end

  private

  def query_params
    params.require(:query)
  end

  def show_query_errors(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  attr_reader :findingaids_query
end
