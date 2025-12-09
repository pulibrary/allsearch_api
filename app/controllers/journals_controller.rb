# frozen_string_literal: true

class JournalsController < RackResponseController
  def initialize(request, env = nil)
    super
    @service = Journals
  end
end
