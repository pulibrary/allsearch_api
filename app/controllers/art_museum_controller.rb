# frozen_string_literal: true

class ArtMuseumController < RackResponseController
  def initialize(request, env)
    super
    @service = ArtMuseum
  end
end
