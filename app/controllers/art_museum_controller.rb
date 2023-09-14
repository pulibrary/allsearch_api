# frozen_string_literal: true

class ArtMuseumController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = ArtMuseum
  end
end
