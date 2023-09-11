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

  def title(document:)
    document[:readonly_title_ssim]&.first
  end

  def creator(document:)
    document[:readonly_creator_ssim]&.first
  end

  def publisher(document:)
    document[:readonly_publisher_ssim]&.first
  end

  def type(document:)
    document[:readonly_format_ssim]&.first
  end

  def description(document:)
    # tbd - nothing in the current json that seems relevant
  end

  def other_fields(document:)
    doc_keys = [:collection]
    parsed_record(document:, doc_keys:)
  end

  def collection(document:)
    document[:readonly_collections_tesim]&.first
  end

  def solr_collection
    'dpul-production'
  end

  def solr_fields
    %w[id readonly_title_ssim readonly_creator_ssim readonly_publisher_ssim readonly_format_ssim
       readonly_collections_tesim].join(',')
  end

  def solr_sort
    'score desc'
  end
end
