# frozen_string_literal: true

class DpulController < RackResponseController
  private

  def json
    Dpul.new(query_terms:).our_response
  end
end
