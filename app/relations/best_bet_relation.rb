#frozen_string_literal: true

require 'dry/types'

class BestBetRelation < ROM::Relation[:sql]
  schema :best_bet_records, infer: true do
    attribute :search_terms, Types::String.constrained(min_size: 3)
    attribute :title, Types::String.constrained(min_size: 1)
    attribute :url, Types::String.constrained(min_size: 1)
  end

  def query(search_term)
    where(Sequel.lit('unaccent(?) ILIKE ANY(search_terms) OR unaccent(?) ILIKE title', search_term, search_term))
  end

  auto_struct true
end
