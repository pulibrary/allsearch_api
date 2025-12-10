# frozen_string_literal: true

class JournalsController < RackResponseController
  def initialize(request, env)
    super
    @service = Journals
  end
end
