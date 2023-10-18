# frozen_string_literal: true

class LibanswersController < ServiceController
  def initialize
    super
    @service = Libanswers
  end
end
