# frozen_string_literal: true

class DpulController < RackResponseController
  def initialize(...)
    super
    @service = Dpul
  end
end
