# frozen_string_literal: true

class JournalsController < ServiceController
  def initialize
    super
    @service = Journals
  end
end
