# frozen_string_literal: true

# This class is responsible for querying the Catalog
class Catalog
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

  def document_class = CatalogDocument

  def solr_fields
    %w[id title_display author_display pub_created_display format holdings_1display electronic_portfolio_s
       electronic_access_1display]
  end

  def solr_sort
    'score desc, pub_date_start_sort desc, title_sort asc'
  end

  def doc_keys = [:title, :creator, :publisher, :id, :type, :description, :url, :other_fields]

  def service = 'catalog'
end
