# frozen_string_literal: true

class BestBetController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = BestBet
  end
end
