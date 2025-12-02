# frozen_string_literal: true

class LibraryDatabaseRecord < ApplicationRecord
  # rubocop:disable Metrics/MethodLength
  def self.new_from_csv(row)
    alt_names_concat = row[3]
    subjects_concat = row[6]
    repository.create(
      libguides_id: row[0],
      name: row[1],
      description: row[2],
      alt_names_concat:,
      url: row[4],
      friendly_url: row[5],
      subjects_concat:,
      alt_names: alt_names_concat&.split('; '),
      subjects: subjects_concat&.split(';')
    )
  end
  # rubocop:enable Metrics/MethodLength

  def self.repository
    @repository ||= LibraryDatabaseRepository.new(Rails.application.config.rom)
  end
end
