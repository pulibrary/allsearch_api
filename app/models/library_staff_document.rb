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

  def section
    document.section
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

  def type
    'Library Staff'
  end

  # Not relevant for this service
  def description; end

  def url
    staff_url = "https://library.psb-prod.princeton.edu/people/#{document.first_name}-#{document.last_name}"
    staff_url.sub(' ', '-')
    staff_url.downcase
  end

  def doc_keys
    [:first_name, :middle_name, :last_name, :netid, :library_title, :phone, :email, :section, :division, :department,
     :unit, :office, :building]
  end
end
