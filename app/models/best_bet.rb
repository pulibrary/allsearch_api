# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for
class BestBet
  include Dry::Monads[:maybe]

  def our_response(query_terms:)
    service_response = service_response(query_terms:)
    {
      number: service_response.count,
      records: records(service_response:)
    }.compact.to_json
  end

  def service_response(query_terms:)
    unescaped_terms = URI::DEFAULT_PARSER.unescape(query_terms)
    best_bet.query(unescaped_terms)
  end

  def records(service_response:)
    service_response.limit(1).map { BestBetDocument.new(it).public_metadata }
  end

  private

  def best_bet
    @best_bet ||= ALLSEARCH_ROM.relations[:best_bet_records]
  end
end
