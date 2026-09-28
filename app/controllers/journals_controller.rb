# frozen_string_literal: true

class JournalsController < RackResponseController
  def initialize(...)
    super
    @service = Journals
  end
end
