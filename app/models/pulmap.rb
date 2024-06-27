# frozen_string_literal: true

# This class is responsible for querying maps.princeton.edu (aka Pulmap)
class Pulmap
  include ActiveModel::API
  include Parsed
  include Solr
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'pulmap'
    @service_response = solr_service_response
  end

  def solr_fields
    %w[layer_slug_s dc_title_s dc_creator_sm dc_publisher_s dc_format_s dc_description_s dc_rights_s layer_geom_type_s]
  end

  def solr_sort
    'score desc'
  end
end
