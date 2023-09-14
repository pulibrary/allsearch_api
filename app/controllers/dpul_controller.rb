# frozen_string_literal: true

class DpulController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = Dpul
  end
end
