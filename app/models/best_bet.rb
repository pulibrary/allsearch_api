# frozen_string_literal: true

# This class is responsible for
class BestBet
  include Parsed
  attr_reader :query_terms, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service_response = best_bet_service_response
  end

  def best_bet_service_response
    BestBetRecord.query(query_terms)
  end

  def number
    service_response.count
  end

  # Not relevant for this service
  def more_link; end

  def documents
    service_response
  end
end
