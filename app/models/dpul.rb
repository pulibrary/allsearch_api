# frozen_string_literal: true

# This class is responsible for querying DPUL
class Dpul
  include ActiveModel::API
  include Parsed
  include Solr

  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'dpul'
    @service_response = solr_service_response
  end

  def solr_fields
    %w[id readonly_title_ssim readonly_creator_ssim readonly_publisher_ssim readonly_format_ssim
       readonly_collections_tesim]
  end

  def solr_sort
    'score desc'
  end

  def extra_solr_params
    'group=true&group.main=true&group.limit=1&group.field=content_metadata_iiif_manifest_field_ssi&group.facet=true'
  end
end
