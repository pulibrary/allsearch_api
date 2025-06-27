# frozen_string_literal: true

# This class is responsible for storing and retrieving relevant
# metadata from the library_staff_record table in the database
class LibraryStaffRecord < ApplicationRecord
  validates :puid, :netid, :name, :email, :title, :library_title, presence: true
  # See https://github.com/pulibrary/allsearch_api/issues/295#issuecomment-2302094168 for context on this search
  scope :query, lambda { |search_term|
                  where(
                    Arel.sql("name_searchable @@ websearch_to_tsquery('unaccented_simple_dict', ?) " \
                             "OR searchable @@ websearch_to_tsquery('unaccented_dict', ?)",
                             search_term, search_term)
                  ).order(
                    Arel.sql('ts_rank(name_searchable || searchable, ' \
                             "websearch_to_tsquery('unaccented_simple_dict', unaccent(?)))",
                             search_term).desc
                  )
                }

  scope :new_query, lambda { |search_term|
                where(
                  Arel.sql(
                           "title_searchable @@ websearch_to_tsquery('unaccented_dict', ?)",
                           search_term)
                )
  }

  # :reek:TooManyStatements
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.new_from_csv(row)
    title = row[13]

    record = LibraryStaffRecord.new
    record.puid = row[0]
    record.netid = row[1]
    record.phone = row[2]
    record.name = row[3]
    record.last_name = row[4]
    record.first_name = row[5]
    record.email = row[6]
    record.office = row[7] # This is called "Address" in the original CSV and Airtable
    record.building = row[8]
    record.department = row[9]
    record.unit = row[11]
    record.areas_of_study = row[14]&.gsub('//', ', ')
    record.my_scheduler_link = row[18]
    record.other_entities = row[19]&.gsub('//', ', ')
    record.library_title = title
    record.title = title
    record.pronouns = row[20]
    valid = record.valid?
    record.save! if valid
    record if valid
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
