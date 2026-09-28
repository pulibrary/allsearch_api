# frozen_string_literal: true

class LibguidesController < RackResponseController
  def initialize(...)
    super
    @service = Libguides
  end
end
