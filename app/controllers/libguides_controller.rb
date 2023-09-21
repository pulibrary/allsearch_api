# frozen_string_literal: true

class LibguidesController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = Libguides
  end
end
