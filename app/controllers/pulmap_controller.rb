# frozen_string_literal: true

class PulmapController < RackResponseController
  def initialize(request, env)
    super
    @service = Pulmap
  end
end
