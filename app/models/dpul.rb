# frozen_string_literal: true

class Dpul
  include ActiveModel::API
  include Parsed
  include Blacklight
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'dpul'
    @service_response = blacklight_service_response(query_terms:, service:)
  end

  def title(document:)
    document.dig(:attributes, :readonly_title_ssim, :attributes, :value)
  end

  def creator(document:)
    document.dig(:attributes, :readonly_creator_ssim, :attributes, :value)
  end

  def publisher(document:)
    document.dig(:attributes, :readonly_publisher_ssim, :attributes, :value)
  end

  def type(document:)
    document.dig(:attributes, :readonly_format_ssim, :attributes, :value)
  end

  def description(document:)
    # tbd - nothing in the current json that seems relevant
  end

  def other_fields(document:)
    doc_keys = [:collection]
    parsed_record(document:, doc_keys:)
  end

  def collection(document:)
    document.dig(:attributes, :readonly_collections_tesim, :attributes, :value)
  end
end
