# frozen_string_literal: true

# This class is responsible for querying the Catalog
class Catalog
  include Parsed
  include Solr

  attr_reader :query_terms, :service, :service_response, :allsearch_config

  def initialize(query_terms:, rom: Rails.application.config.rom, allsearch_config: ALLSEARCH_CONFIGS[:allsearch])
    @query_terms = query_terms
    @allsearch_config = allsearch_config
    @service = 'catalog'
    @service_response = solr_service_response
  end

  def solr_fields
    %w[id title_display author_display pub_created_display format holdings_1display electronic_portfolio_s
       electronic_access_1display]
  end

  def solr_sort
    'score desc, pub_date_start_sort desc, title_sort asc'
  end
end
