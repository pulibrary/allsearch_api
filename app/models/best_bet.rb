# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for
class BestBet
  include Dry::Monads[:maybe]

  attr_reader :query_terms

  def initialize(query_terms:)
    @query_terms = query_terms
  end

  def our_response
    {
      number: number,
      records:
    }.compact.to_json
  end

  def number
    service_response.count
  end

  def service_response
    unescaped_terms = URI::DEFAULT_PARSER.unescape(query_terms)
    @service_response ||= best_bet.query(unescaped_terms)
  end

  def records
    service_response.limit(1).map { BestBetDocument.new(it).public_metadata }
  end

  private

  def best_bet
    @best_bet ||= Rails.application.config.rom.relations[:best_bet_records]
  end
end
