# frozen_string_literal: true

# This class is responsible for storing and retrieving relevant
# metadata from the best_bet_record table in the database
class BestBetRecord < ApplicationRecord
  validates :title, :url, :search_terms, presence: true
  scope :query, lambda { |search_term|
                  where('unaccent(?) ILIKE ANY(search_terms) OR unaccent(?) ILIKE title', search_term, search_term)
                }
  def self.new_from_csv(row)
    BestBetRecord.create!(
      title: row[0],
      description: row[1],
      url: row[2],
      search_terms: row[3]&.split(', ')&.map { |term| Normalizer.new(term).without_diacritics },
      last_update: last_update(row)
    )
  rescue ActiveRecord::RecordInvalid => error
    Rails.logger.error("Could not create new BestBet for row #{row}: #{error.message}")
  end

  def self.last_update(row)
    update = row[4]
    return nil if update.blank?

    Date.strptime(update, '%B %d, %Y')
  rescue Date::Error
    Rails.logger.info("Invalid date for BestBet row: #{row}")
  end
end
