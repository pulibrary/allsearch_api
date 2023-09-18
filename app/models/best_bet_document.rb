# frozen_string_literal: true

# This class is responsible for storing and retrieving relevant
# metadata from the best_bet_document table in the database
class BestBetDocument < ApplicationRecord
  scope :query, ->(search_term) { where('? = ANY(search_terms)', search_term) }
  # :reek:TooManyStatements
  def self.new_from_csv(row)
    document = BestBetDocument.new
    document.title = row[0]
    document.description = row[1]
    document.url = row[2]
    document.search_terms = row[3].split(', ')
    document.last_update = Date.strptime(row[4], '%B %d, %Y')
    document.save
  end
end
