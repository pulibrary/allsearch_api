# frozen_string_literal: true

require 'rom-repository'
require allsearch_path 'init/logger'

class BestBetRepository < ROM::Repository[:best_bet_records]
  commands :create,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:created_at, :updated_at] } }
  commands :delete

  # rubocop:disable Metrics/MethodLength
  # :reek:FeatureEnvy
  # :reek:NestedIterators
  # :reek:TooManyStatements
  def new_from_csv(rows)
    entries = rows.map do |row|
      {
        title: row[0],
        description: row[1],
        url: row[2],
        search_terms: "{#{row[3]&.split(', ')&.map { |term| Normalizer.new(term).without_diacritics }&.join(', ')}}",
        last_update: last_update(row)
      }
    end
    create entries
  rescue Dry::Types::SchemaError => error
    ALLSEARCH_LOGGER.error("Could not create new BestBet for row: #{error.message}")
  end
  # rubocop:enable Metrics/MethodLength

  # :reek:UtilityFunction
  def last_update(row)
    update = row[4]
    return nil if update&.empty?

    Date.strptime(update, '%B %d, %Y')
  rescue Date::Error
    ALLSEARCH_LOGGER.info("Invalid date for BestBet row: #{row}")
  end
end
