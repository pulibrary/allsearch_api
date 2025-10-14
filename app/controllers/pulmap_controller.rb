# frozen_string_literal: true

class PulmapController < RackResponseController
  def initialize(request)
    super
    @service = Pulmap
  end
end
