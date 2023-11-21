# frozen_string_literal: true

# This class is responsible for storing and retrieving relevant
# metadata from the library_staff_record table in the database
class LibraryStaffRecord < ApplicationRecord
    scope :query, ->(search_term) { where('last_name ILIKE :search OR first_name ILIKE :search OR middle_name ILIKE :search OR title ILIKE :search OR library_title ILIKE :search OR email ILIKE :search OR department ILIKE :search OR office ILIKE :search OR building ILIKE :search', search: search_term) }
    # :reek:TooManyStatements
    def self.new_from_csv(row)
      record = LibraryStaffRecord.new
      record.puid = row[0]
      record.netid = row[1]
      record.phone = row[2]
      record.name = row[3]
      record.last_name = row[4]
      record.first_name = row[5]
      record.middle_name = row[6]
      record.title = row[7]
      record.library_title = row[8]
      record.email = row[10]
      record.section = row[11]
      record.division = row[12]
      record.department = row[13]
      record.unit = row[18]
      record.office = row[23]
      record.building = row[24]
      record.save
    end
  end
