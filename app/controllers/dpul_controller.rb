# frozen_string_literal: true

class DpulController < ServiceController
  def initialize
    super
    @service = Dpul
  end
end
