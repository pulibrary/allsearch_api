# frozen_string_literal: true

CSV_FIELDS = [:libguides_id, :name, :description, :alt_names_concat, :url, :friendly_url, :subjects_concat].freeze

class LibraryDatabaseRecord < ApplicationRecord
  scope :query, ->(search_term) { where("searchable @@ websearch_to_tsquery('english', ?)", search_term) }

  # :reek:TooManyStatements
  def self.new_from_csv(row)
    record = LibraryDatabaseRecord.new
    CSV_FIELDS.each_with_index { |field, index| record.method(:"#{field}=").call(row[index]) }
    record.alt_names = record.alt_names_concat&.split('; ')
    record.subjects = record.subjects_concat&.split(';')
    record.save
  end
end
