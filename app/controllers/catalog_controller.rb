# frozen_string_literal: true

class CatalogController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = Catalog
  end
end
