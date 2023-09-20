# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the Art Museum's JSON
# The document is a Hash
class ArtMuseumDocument < Document
  private

  def id
    document[:_id]
  end

  def title
    document.dig(:_source, :displaytitle)
  end

  def creator
    document.dig(:_source, :displaymaker)
  end

  def publisher
    # tbd - nothing in the current json that seems relevant
  end

  def type
    document[:_type]
  end

  def description
    # tbd - nothing in the current json that seems relevant
  end

  def url
    URI::HTTPS.build(host: 'artmuseum.princeton.edu', path: "/collections/objects/#{id}")
  end

  def doc_keys
    [:credit_line, :medium, :dimensions, :primary_image, :object_number]
  end

  def credit_line
    document.dig(:_source, :creditline)
  end

  def medium
    document.dig(:_source, :medium)
  end

  def dimensions
    document.dig(:_source, :dimensions)
  end

  def primary_image
    document.dig(:_source, :primaryimage)&.first
  end

  def object_number
    document.dig(:_source, :objectnumber)
  end
end
