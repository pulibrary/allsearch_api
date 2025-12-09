# frozen_string_literal: true

require 'rom-repository'

class LibraryStaffRepository < ROM::Repository[:library_staff_records]
  commands :create,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:created_at, :updated_at] } }
  commands :delete

  # rubocop:disable Metrics/MethodLength
  # :reek:FeatureEnvy
  # :reek:DuplicateMethodCall
  def new_from_csv(rows)
    entries = rows.map do |row|
      {
        title: row[13],
        puid: row[0],
        netid: row[1],
        phone: row[2],
        name: row[3],
        last_name: row[4],
        first_name: row[5],
        email: row[6],
        office: row[7], # This is called "Address" in the original CSV and Airtable
        building: row[8],
        department: row[9],
        unit: row[11],
        areas_of_study: row[14]&.gsub('//', ', '),
        bio: row[16],
        my_scheduler_link: row[18],
        other_entities: row[19]&.gsub('//', ', '),
        library_title: row[13],
        pronouns: row[20]
      }
    end
    create entries
  end
  # rubocop:enable Metrics/MethodLength
end