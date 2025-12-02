# frozen_string_literal: true

require 'rom-repository'

class LibraryDatabaseRepository < ROM::Repository[:library_database_records]
  commands :create,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:created_at, :updated_at] } }
  commands :delete

  # rubocop:disable Metrics/MethodLength
  # :reek:FeatureEnvy
  def create_from_csv(rows)
    entries = rows.map do |row|
      alt_names_concat = row[3]
      subjects_concat = row[6]
      {
        libguides_id: row[0],
        name: row[1],
        description: row[2],
        alt_names_concat:,
        url: row[4],
        friendly_url: row[5],
        subjects_concat:,
        alt_names: alt_names_concat&.split('; '),
        subjects: subjects_concat&.split(';')
      }
    end
    create entries
  end
  # rubocop:enable Metrics/MethodLength
end
