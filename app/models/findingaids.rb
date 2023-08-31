# frozen_string_literal: true

class Findingaids
  include ActiveModel::API
  include Parsed
  include Blacklight
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'findingaids'
    @service_response = blacklight_service_response(query_terms:, service:)
  end

  # Use the collection name as the title?
  def title(document:)
    document.dig(:attributes, :collection_ssm, :attributes, :value)
  end

  def creator(document:)
    document.dig(:attributes, :creator_ssm, :attributes, :value)
  end

  # No sensible field to map to this currently
  def publisher(document:)
    # tbd - nothing in the current json that seems relevant
  end

  def type(document:)
    document[:type]
  end

  # This field may contain html
  def description(document:)
    document.dig(:attributes, :scopecontent_ssm, :attributes, :value)
  end

  def other_fields(document:)
    doc_keys = [:repository, :extent, :access_restriction]
    parsed_record(document:, doc_keys:)
  end

  def repository(document:)
    document.dig(:attributes, :repository_ssm, :attributes, :value)
  end

  def extent(document:)
    document.dig(:attributes, :extent_ssm, :attributes, :value)
  end

  def access_restriction(document:)
    document.dig(:attributes, :accessrestrict_ssm, :attributes, :value)
  end
end
