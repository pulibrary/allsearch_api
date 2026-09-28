# frozen_string_literal: true

class LibanswersController < RackResponseController
  def initialize(...)
    super
    @service = Libanswers
  end
end
