# frozen_string_literal: true

# This class is responsible for translating LibraryDatabaseRecords, originally from LibGuides,
# into an API response
class LibraryDatabase
  attr_reader :query_terms

  def initialize(query_terms:)
    @query_terms = query_terms
  end

  def our_response
    {
      number:,
      records:,
      more: more_link
    }.to_json
  end

  def service_response
    @service_response ||= library_databases.query(unescaped_terms)
  end

  def unescaped_terms
    @unescaped_terms ||= URI::DEFAULT_PARSER.unescape(query_terms)
  end

  # The libguides search does not treat accented characters consistently
  # Always use the unaccented version for the "more_link"
  def transliterated_escaped_terms
    URI::DEFAULT_PARSER.escape(Normalizer.new(unescaped_terms).without_diacritics)
  end

  def number
    service_response.count
  end

  def more_link
    URI::HTTPS.build(host: 'libguides.princeton.edu', path: '/az/databases',
                     query: "q=#{transliterated_escaped_terms}")
  end

  def records
    service_response.limit(3).map { LibraryDatabaseDocument.new(it).public_metadata }
  end

  private

  def library_databases
    @library_databases ||= Rails.application.config.rom.relations[:library_database_records]
  end
end
