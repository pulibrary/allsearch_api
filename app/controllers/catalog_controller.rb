# frozen_string_literal: true

class CatalogController < RackResponseController
  def initialize(...)
    super
    @service = Catalog
  end
end
