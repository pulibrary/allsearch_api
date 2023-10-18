# frozen_string_literal: true

class LibguidesController < ServiceController
  def initialize
    super
    @service = Libguides
  end
end
