# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the LibraryStaffRecords in the database
# The document is a LibraryStaffRecord
# :reek:TooManyMethods
class LibraryStaffDocument
  def initialize(attributes)
    @attributes = attributes
  end

  # rubocop:disable Metrics/MethodLength
  def public_metadata
    {
      id:,
      title:,
      type: 'Library Staff',
      url:,
      other_fields: {
        building:,
        department:,
        email:,
        first_name:,
        last_name:,
        library_title:,
        office:,
        phone:,
        unit:,
        netid:,
        pronouns:
      }
    }.compact
  end
  # rubocop:enable Metrics/MethodLength

  private

  attr_reader :attributes

  # Use the full name as the document title
  def title
    attributes[:name]
  end

  def first_name
    attributes[:first_name]
  end

  def last_name
    attributes[:last_name]
  end

  def id
    attributes[:puid].to_s
  end

  def netid
    attributes[:netid]
  end

  def phone
    attributes[:phone]
  end

  def email
    attributes[:email]
  end

  def library_title
    attributes[:library_title]
  end

  def department
    attributes[:department]
  end

  def unit
    attributes[:unit]
  end

  def office
    attributes[:office]
  end

  def building
    attributes[:building]
  end

  def pronouns
    attributes[:pronouns]
  end

  def url
    path = "/about/staff-directory/#{name_to_path}"
    URI::HTTPS.build(host: LibraryWebsite.library_website_host, path:)
  end

  def name_to_path
    URI::DEFAULT_PARSER.escape("#{attributes[:first_name]}-#{attributes[:last_name]}".delete(".'").gsub(' ',
                                                                                                        '-').downcase)
  end
end
