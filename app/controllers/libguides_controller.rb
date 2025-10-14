# frozen_string_literal: true

class LibguidesController < RackResponseController
  def initialize(request)
    super
    @service = Libguides
  end
end
