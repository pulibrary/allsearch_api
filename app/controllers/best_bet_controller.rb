# frozen_string_literal: true

class BestBetController < RackResponseController
  def initialize(request)
    super
    @service = BestBet
  end
end
