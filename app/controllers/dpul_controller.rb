# frozen_string_literal: true

class DpulController < RackResponseController
  def initialize(request, env)
    super
    @service = Dpul
  end
end
