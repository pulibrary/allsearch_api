# frozen_string_literal: true

# This class is responsible for translating LibraryStaffRecords
# into an API response
class LibraryStaff
  include Parsed
  attr_reader :query_terms, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service_response = library_staff_service_response
  end

  def library_staff_service_response
    LibraryStaffRecord.query(query_terms).limit(3)
  end

  def number
    service_response.count
  end

  def more_link
    URI::HTTPS.build(host: 'library.princeton.edu', path: '/staff/directory',
                     query: "search_api_views_fulltext=#{query_terms}")
  end

  def documents
    service_response
  end
end
