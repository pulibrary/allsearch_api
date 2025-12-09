# frozen_string_literal: true

class LibanswersController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = Libanswers
  end
end
