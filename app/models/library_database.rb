# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for translating LibraryDatabaseRecords, originally from LibGuides,
# into an API response
class LibraryDatabase
  include Dry::Monads[:maybe]

  def initialize(rom: ALLSEARCH_ROM)
    @rom = rom
  end

  def our_response(query_terms:)
    service_response = service_response(query_terms:)
    {
      number: service_response.count,
      records: records(service_response:),
      more: more_link(query_terms:).value_or(nil)
    }.compact.to_json
  end

  def service_response(query_terms:)
    URI::DEFAULT_PARSER.unescape(query_terms)
                       .then { library_databases.query(it) }
  end

  # The libguides search does not treat accented characters consistently
  # Always use the unaccented version for the "more_link"
  def transliterated_escaped_terms(query_terms:)
    URI::DEFAULT_PARSER.unescape(query_terms)
                       .then { Normalizer.new(it).without_diacritics }
                       .then { URI::DEFAULT_PARSER.escape it }
  end

  def more_link(query_terms:)
    Some(URI::HTTPS.build(host: 'libguides.princeton.edu', path: '/az/databases',
                          query: "q=#{transliterated_escaped_terms(query_terms:)}"))
  end

  def records(service_response:)
    service_response.limit(3).map { LibraryDatabaseDocument.new(it).public_metadata }
  end

  private

  attr_reader :rom

  def library_databases
    @library_databases ||= rom.relations[:library_database_records]
  end
end
