# frozen_string_literal: true

class JournalsController < RackResponseController
  def initialize(request)
    super
    @service = Journals
  end
end
