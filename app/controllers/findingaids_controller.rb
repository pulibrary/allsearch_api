# frozen_string_literal: true

class FindingaidsController < RackResponseController
  private

  def json
    Findingaids.new(query_terms:).our_response
  end
end
