# frozen_string_literal: true

# This class is responsible for querying DPUL
class Dpul
  include Parsed
  include Solr

  attr_reader :query_terms, :service, :service_response, :allsearch_config

  def initialize(query_terms:, rom: Rails.application.config.rom, allsearch_config: ALLSEARCH_CONFIGS[:allsearch])
    @query_terms = query_terms
    @allsearch_config = allsearch_config
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
