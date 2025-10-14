# frozen_string_literal: true

class LibanswersController < RackResponseController
  def initialize(request)
    super
    @service = Libanswers
  end
end
