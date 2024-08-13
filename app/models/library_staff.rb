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
    unescaped_terms = URI::DEFAULT_PARSER.unescape(query_terms)
    LibraryStaffRecord.query(unescaped_terms)
  end

  def number
    service_response.count
  end

  def more_link
    URI::HTTPS.build(host: 'library.princeton.edu', path: '/about/staff-directory',
                     query: "combine=#{query_terms}")
  end

  def documents
    service_response.first(3)
  end
end
