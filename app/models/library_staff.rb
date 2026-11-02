# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for translating LibraryStaffRecords
# into an API response
class LibraryStaff
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
    unescaped_terms = URI::DEFAULT_PARSER.unescape(query_terms)
    library_staff.query(unescaped_terms)
  end

  def more_link(query_terms:)
    Some(URI::HTTPS.build(host: 'library.princeton.edu', path: '/about/staff-directory',
                          query: "combine=#{query_terms}"))
  end

  def records(service_response:)
    service_response.limit(3).map { LibraryStaffDocument.new(it).public_metadata }
  end

  private

  attr_reader :rom

  def library_staff
    @library_staff ||= rom.relations[:library_staff_records]
  end
end
