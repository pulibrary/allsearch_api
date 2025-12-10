# frozen_string_literal: true

class BestBetController < RackResponseController
  def initialize(request, env)
    super
    @service = BestBet
  end
end
