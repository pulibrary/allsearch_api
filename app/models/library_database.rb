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
    LibraryDatabaseRecord.query(query_terms).limit(3)
  end

  def number
    service_response.count
  end

  def more_link
    URI::HTTPS.build(host: 'libguides.princeton.edu', path: '/az.php',
                     query: "q=#{query_terms}")
  end

  def documents
    service_response
  end
end
