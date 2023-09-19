# frozen_string_literal: true

class LibanswersController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = Libanswers
  end
end
