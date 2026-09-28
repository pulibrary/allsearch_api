# frozen_string_literal: true

class ArtMuseumController < RackResponseController
  def initialize(...)
    super
    @service = ArtMuseum
  end
end
