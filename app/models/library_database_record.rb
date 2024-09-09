# frozen_string_literal: true

LIBRARY_DATABASE_CSV_FIELDS = [:libguides_id, :name, :description, :alt_names_concat, :url,
                               :friendly_url, :subjects_concat].freeze

class LibraryDatabaseRecord < ApplicationRecord
  include PgSearch::Model

  scope :query, lambda { |search_term|
                  where(
                    Arel.sql("searchable @@ websearch_to_tsquery('unaccented_dict', unaccent(?))",
                             search_term)
                  ).order(
                    Arel.sql("ts_rank(searchable, websearch_to_tsquery('unaccented_dict', unaccent(?)))",
                             search_term).desc
                  )
                }

  # :reek:TooManyStatements
  def self.new_from_csv(row)
    record = LibraryDatabaseRecord.new
    LIBRARY_DATABASE_CSV_FIELDS.each_with_index { |field, index| record.method(:"#{field}=").call(row[index]) }
    record.alt_names = record.alt_names_concat&.split('; ')
    record.subjects = record.subjects_concat&.split(';')
    record.save
    record
  end
end
