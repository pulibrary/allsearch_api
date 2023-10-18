# frozen_string_literal: true

class ArtMuseumController < ServiceController
  def initialize
    super
    @service = ArtMuseum
  end
end
