# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from Pulmap's JSON
class PulmapDocument < Document
  private

  def id
    json[:uuid]
  end

  def url
    "https://maps.princeton.edu/catalog/#{id}"
  end

  def title
    json[:dc_title_s]
  end

  def creator
    json[:dc_creator_sm]&.first
  end

  def publisher
    json[:dc_publisher_s]
  end

  def type
    json[:dc_format_s]
  end

  def description
    json[:dc_description_s]
  end

  def doc_keys
    [:rights, :layer_geom_type]
  end

  def rights
    json[:dc_rights_s]
  end

  def layer_geom_type
    json[:layer_geom_type_s]
  end
end
