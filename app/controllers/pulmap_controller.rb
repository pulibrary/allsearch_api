# frozen_string_literal: true

class PulmapController < ServiceController
  def initialize
    super
    @service = Pulmap
  end
end
