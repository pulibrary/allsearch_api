# frozen_string_literal: true

class CatalogController < ServiceController
  def initialize
    super
    @service = Catalog
  end
end
