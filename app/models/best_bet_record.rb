# frozen_string_literal: true

# This class is responsible for storing and retrieving relevant
# metadata from the best_bet_record table in the database
class BestBetRecord < ApplicationRecord
  scope :query, ->(search_term) { where('? ILIKE ANY(search_terms)', search_term) }
  # :reek:TooManyStatements
  def self.new_from_csv(row)
    record = BestBetRecord.new
    record.title = row[0]
    record.description = row[1]
    record.url = row[2]
    record.search_terms = row[3].split(', ')
    record.last_update = Date.strptime(row[4], '%B %d, %Y')
    record.save
  end
end
