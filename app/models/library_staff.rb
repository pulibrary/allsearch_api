# frozen_string_literal: true

require 'dry-monads'

# This class is responsible for translating LibraryStaffRecords
# into an API response
class LibraryStaff
  include Dry::Monads[:maybe]

  attr_reader :query_terms

  def initialize(query_terms:, rom: ALLSEARCH_ROM)
    @query_terms = query_terms
    @rom = rom
  end

  def our_response
    {
      number:,
      records:,
      more: more_link.value_or(nil)
    }.compact.to_json
  end

  def service_response
    unescaped_terms = URI::DEFAULT_PARSER.unescape(query_terms)
    @service_response ||= library_staff.query(unescaped_terms)
  end

  def number
    service_response.count
  end

  def more_link
    Some(URI::HTTPS.build(host: 'library.princeton.edu', path: '/about/staff-directory',
                          query: "combine=#{query_terms}"))
  end

  def records
    service_response.limit(3).map { LibraryStaffDocument.new(it).public_metadata }
  end

  private

  attr_reader :rom

  def library_staff
    @library_staff ||= rom.relations[:library_staff_records]
  end
end
