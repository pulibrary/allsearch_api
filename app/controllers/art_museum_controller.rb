# frozen_string_literal: true

class ArtMuseumController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = ArtMuseum
  end
end
