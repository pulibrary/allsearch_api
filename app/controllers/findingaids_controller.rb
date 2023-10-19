# frozen_string_literal: true

class FindingaidsController < ServiceController
  def initialize
    super
    @service = Findingaids
  end
end
