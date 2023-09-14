# frozen_string_literal: true

class FindingaidsController < ServiceController
  rescue_from ActionController::ParameterMissing, with: :show_query_errors

  def initialize
    super
    @service = Findingaids
  end
end
