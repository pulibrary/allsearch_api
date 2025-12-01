# frozen_string_literal: true

# This class is responsible for querying the Catalog
class Catalog
  include ActiveModel::API
  include Parsed
  include Solr

  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
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
