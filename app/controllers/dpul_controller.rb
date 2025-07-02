# frozen_string_literal: true

class DpulController < RackResponseController
  def initialize(request)
    super
    @service = Dpul
  end
end
