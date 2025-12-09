# frozen_string_literal: true

class BestBetController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = BestBet
  end
end
