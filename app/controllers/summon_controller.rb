# frozen_string_literal: true

class SummonController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = Summon
  end
end
