# frozen_string_literal: true

# This class is responsible for querying maps.princeton.edu (aka Pulmap)
class Pulmap
  include Solr

  attr_reader :query_terms, :service_response, :allsearch_config

  def initialize(query_terms:, allsearch_config: ALLSEARCH_CONFIGS[:allsearch])
    @query_terms = query_terms
    @allsearch_config = allsearch_config
    @service_response = solr_service_response
  end

  def our_response
    {
      number:,
      records: documents.map { |document| document_class.new(document:, doc_keys:).to_h },
      more: more_link.value_or(nil)
    }.compact.to_json
  end

  private

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]
  def document_class = PulmapDocument
  def service = 'pulmap'

  def solr_fields
    %w[layer_slug_s dc_title_s dc_creator_sm dc_publisher_s dc_format_s dc_description_s dc_rights_s
       layer_geom_type_s]
  end

  def solr_sort
    'score desc'
  end
end
