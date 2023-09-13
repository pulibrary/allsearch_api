# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the Art Museum's JSON
class ArtMuseumDocument < Document
  private

  def id
    json[:_id]
  end

  def title
    json.dig(:_source, :displaytitle)
  end

  def creator
    json.dig(:_source, :displaymaker)
  end

  def publisher
    # tbd - nothing in the current json that seems relevant
  end

  def type
    json[:_type]
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
    json.dig(:_source, :creditline)
  end

  def medium
    json.dig(:_source, :medium)
  end

  def dimensions
    json.dig(:_source, :dimensions)
  end

  def primary_image
    json.dig(:_source, :primaryimage)&.first
  end

  def object_number
    json.dig(:_source, :objectnumber)
  end
end
