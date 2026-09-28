# frozen_string_literal: true

class PulmapController < RackResponseController
  def initialize(...)
    super
    @service = Pulmap
  end
end
