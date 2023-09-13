# frozen_string_literal: true

class Dpul
  include ActiveModel::API
  include Parsed
  include Solr
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'dpul'
    @service_response = solr_service_response(query_terms:)
  end

  def solr_fields
    %w[id readonly_title_ssim readonly_creator_ssim readonly_publisher_ssim readonly_format_ssim
       readonly_collections_tesim].join(',')
  end

  def solr_sort
    'score desc'
  end
end
