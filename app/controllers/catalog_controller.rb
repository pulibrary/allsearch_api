# frozen_string_literal: true

class CatalogController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = Catalog
  end
end
