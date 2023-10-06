# frozen_string_literal: true

class SummonApiController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = SummonApi
  end
end
