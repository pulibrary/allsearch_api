# frozen_string_literal: true

# This class is responsible for
class LibraryDatabase
  include Parsed
  attr_reader :query_terms, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service_response = library_database_service_response
  end

  def library_database_service_response
    LibraryDatabaseRecord.query(query_terms)
  end

  def number
    service_response.count
  end

  # Not relevant for this service
  def more_link; end

  def documents
    service_response
  end
end
