# frozen_string_literal: true

class CatalogController < RackResponseController
  def initialize(request)
    super
    @service = Catalog
  end
end
