# frozen_string_literal: true

class LibguidesController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = Libguides
  end
end
