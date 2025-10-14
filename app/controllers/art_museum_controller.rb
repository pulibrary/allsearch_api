# frozen_string_literal: true

class ArtMuseumController < RackResponseController
  def initialize(request)
    super
    @service = ArtMuseum
  end
end
