# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from Pulmap's JSON
class PulmapDocument < Document
  include SolrDocument

  def initialize(document:, doc_keys:, environment: Environment.new)
    super(document:, doc_keys:)
    @environment = environment
  end

  private

  attr_reader :environment

  def service
    'pulmap'
  end

  def id
    document[:layer_slug_s]
  end

  def title
    document[:dc_title_s]
  end

  def creator
    document[:dc_creator_sm]&.first
  end

  def publisher
    document[:dc_publisher_s]
  end

  def type
    document[:dc_format_s]
  end

  def description
    sanitize document[:dc_description_s]
  end

  def doc_keys
    [:rights, :layer_geom_type]
  end

  def rights
    document[:dc_rights_s]
  end

  def layer_geom_type
    document[:layer_geom_type_s]
  end
end
