# frozen_string_literal: true

class Catalog
  include ActiveModel::API
  include Parsed
  include Blacklight
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'catalog'
    @service_response = blacklight_service_response(query_terms:, service:)
  end

  def title(document:)
    document.dig(:attributes, :title)
  end

  def creator(document:)
    document.dig(:attributes, :author_display, :attributes, :value)&.first
  end

  def publisher(document:)
    document.dig(:attributes, :pub_created_display, :attributes, :value)&.first
  end

  def type(document:)
    document.dig(:attributes, :format, :attributes, :value)&.first
  end

  def description(document:)
    # tbd - nothing in the current json that seems relevant
  end

  def other_fields(document:)
    doc_keys = %i[call_number library]
    parsed_record(document:, doc_keys:)
  end

  def first_holding(document:)
    document.dig(:attributes, :holdings_1display, :attributes, :value)&.first&.last
  end

  def call_number(document:)
    first_holding(document:)&.dig(:call_number)
  end

  def library(document:)
    first_holding(document:)&.dig(:library)
  end
end
