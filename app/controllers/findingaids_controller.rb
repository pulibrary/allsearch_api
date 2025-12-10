# frozen_string_literal: true

class FindingaidsController < RackResponseController
  def initialize(request, env)
    super
    @service = Findingaids
  end
end
