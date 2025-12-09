# frozen_string_literal: true

class PulmapController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = Pulmap
  end
end
