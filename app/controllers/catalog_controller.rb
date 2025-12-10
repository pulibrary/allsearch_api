# frozen_string_literal: true

class CatalogController < RackResponseController
  def initialize(request, env)
    super
    @service = Catalog
  end
end
