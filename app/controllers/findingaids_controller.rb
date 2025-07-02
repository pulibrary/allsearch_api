# frozen_string_literal: true

class FindingaidsController < RackResponseController
  def initialize(request)
    super
    @service = Findingaids
  end
end
