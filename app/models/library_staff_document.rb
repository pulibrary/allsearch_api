# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the LibraryStaffRecords in the database
# The document is a LibraryStaffRecord
# :reek:TooManyMethods
class LibraryStaffDocument < Document
  private

  # Use the full name as the document title
  def title
    document.name
  end

  def first_name
    document.first_name
  end

  def middle_name
    document.middle_name
  end

  def last_name
    document.last_name
  end

  # Not relevant for this service
  def creator; end

  # Not relevant for this service
  def publisher; end

  def id
    document.puid
  end

  def netid
    document.netid
  end

  def phone
    document.phone
  end

  def email
    document.email
  end

  def library_title
    document.library_title
  end

  def team
    document.team
  end

  def division
    document.division
  end

  def department
    document.department
  end

  def unit
    document.unit
  end

  def office
    document.office
  end

  def building
    document.building
  end

  def pronouns
    document.pronouns
  end

  def type
    'Library Staff'
  end

  # Not relevant for this service
  def description; end

  def url
    path = "/about/staff-directory/#{name_to_path}"
    URI::HTTPS.build(host: LibraryWebsite.library_website_host, path:)
  end

  def name_to_path
    URI::DEFAULT_PARSER.escape("#{document.first_name}-#{document.last_name}".gsub(' ', '-').downcase)
  end

  def doc_keys
    [:first_name, :middle_name, :last_name, :netid, :library_title, :phone, :email, :team, :division, :department,
     :unit, :office, :building, :pronouns]
  end
end
