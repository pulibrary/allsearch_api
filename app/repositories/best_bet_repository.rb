#frozen_string_literal: true

require 'rom-repository'

class BestBetRepository < ROM::Repository[:best_bet_records]
  commands :create,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:created_at, :updated_at] } }
  commands :delete

  def new_from_csv(rows)
    entries = rows.map do |row|
      {
        title: row[0],
        description: row[1],
        url: row[2],
        search_terms: "{#{row[3]&.split(', ')&.map { |term| Normalizer.new(term).without_diacritics}.join(', ')}}",
        last_update: last_update(row)
      }
    end
    create entries
  rescue Dry::Types::SchemaError => error
    Rails.logger.error("Could not create new BestBet for row: #{error.message}")
  end

  def last_update(row)
    update = row[4]
    return nil if update.blank?

    Date.strptime(update, '%B %d, %Y')
  rescue Date::Error
    Rails.logger.info("Invalid date for BestBet row: #{row}")
  end
end
