# frozen_string_literal: true

class DpulController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = Dpul
  end
end
