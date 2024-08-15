# frozen_string_literal: true

LIBRARY_DATABASE_CSV_FIELDS = [:libguides_id, :name, :description, :alt_names_concat, :url,
                               :friendly_url, :subjects_concat].freeze

class LibraryDatabaseRecord < ApplicationRecord
  include PgSearch::Model

  # See https://pganalyze.com/blog/full-text-search-ruby-rails-postgres for more on this type of search
  pg_search_scope :query,
                  against: 'searchable',
                  ignoring: :accents,
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'searchable'
                    }
                  }

  # :reek:TooManyStatements
  def self.new_from_csv(row)
    record = LibraryDatabaseRecord.new
    LIBRARY_DATABASE_CSV_FIELDS.each_with_index { |field, index| record.method(:"#{field}=").call(row[index]) }
    record.alt_names = record.alt_names_concat&.split('; ')
    record.subjects = record.subjects_concat&.split(';')
    record.save
  end
end
