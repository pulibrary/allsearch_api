# frozen_string_literal: true

class LibguidesController < RackResponseController
  def initialize(request, env)
    super
    @service = Libguides
  end
end
