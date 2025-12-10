# frozen_string_literal: true

class LibanswersController < RackResponseController
  def initialize(request, env)
    super
    @service = Libanswers
  end
end
