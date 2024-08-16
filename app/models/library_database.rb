# frozen_string_literal: true

# This class is responsible for translating LibraryDatabaseRecords, originally from LibGuides,
# into an API response
class LibraryDatabase
  include Parsed
  attr_reader :query_terms, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service_response = library_database_service_response
  end

  def library_database_service_response
    LibraryDatabaseRecord.query(unescaped_terms)
  end

  def unescaped_terms
    @unescaped_terms ||= URI::DEFAULT_PARSER.unescape(query_terms)
  end

  # The libguides search does not treat accented characters consistently
  # Always use the unaccented version for the "more_link"
  def transliterated_escaped_terms
    diacritic_combining_characters = [*0x1DC0..0x1DFF, *0x0300..0x036F, *0xFE20..0xFE2F].pack('U*')
    decomposed_version = unescaped_terms.unicode_normalize(:nfd)
    decomposed_without_combining_characters = decomposed_version.tr(diacritic_combining_characters, '')
    URI::DEFAULT_PARSER.escape(decomposed_without_combining_characters)
  end

  def number
    service_response.count
  end

  def more_link
    URI::HTTPS.build(host: 'libguides.princeton.edu', path: '/az/databases',
                     query: "q=#{transliterated_escaped_terms}")
  end

  def documents
    service_response.first(3)
  end
end
