# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the LibraryDatabaseRecord in the database
# The document is a LibraryDatabaseRecord
class LibraryDatabaseDocument < Document
  private

  def title
    document.name
  end

  # Not relevant for this service
  def creator; end

  # Not relevant for this service
  def publisher; end

  def id
    document.libguides_id
  end

  def type
    'Database'
  end

  def description
    ActionView::Base.full_sanitizer.sanitize(document.description)
  end

  def url
    document.friendly_url
  end

  def doc_keys
    [:subjects, :alternative_titles]
  end

  def subjects
    document.subjects&.join(', ')
  end

  def alternative_titles
    document.alt_names&.join(', ')
  end
end
