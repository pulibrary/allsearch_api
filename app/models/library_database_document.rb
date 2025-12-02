# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the LibraryDatabaseRelation in the database
class LibraryDatabaseDocument
  def initialize(attributes)
    @attributes = attributes
  end

  # Returns a hash that can be included in the JSON response
  # rubocop:disable Metrics/MethodLength
  def public_metadata
    {
      title: attributes[:name],
      id: attributes[:libguides_id]&.to_s,
      type: 'Database',
      description: sanitize(attributes[:description]),
      url: attributes[:friendly_url],
      other_fields: {
        subjects: subjects,
        alternative_titles: alternative_titles
      }
    }.compact
  end
  # rubocop:enable Metrics/MethodLength

  private

  attr_reader :attributes

  def subjects
    attributes[:subjects]&.join(', ')
  end

  def alternative_titles
    attributes[:alt_names]&.join(', ')
  end

  def sanitizer
    @sanitizer ||= Sanitizer.new
  end

  def sanitize(text)
    return text if text.blank?

    sanitizer.sanitize(text, scrubber: TextScrubber.new)
  end
end
