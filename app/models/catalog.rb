# frozen_string_literal: true

class Catalog
  include ActiveModel::API
  include Parsed
  include Solr
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'catalog'
    @service_response = solr_service_response(query_terms:)
  end

  def title(document:)
    document[:title_display]
  end

  def creator(document:)
    document[:author_display]&.first
  end

  def publisher(document:)
    document[:pub_created_display]&.first
  end

  def type(document:)
    document[:format]&.first
  end

  def description(document:)
    # tbd - nothing in the current json that seems relevant
  end

  def other_fields(document:)
    doc_keys = [:call_number, :library]
    parsed_record(document:, doc_keys:)
  end

  def first_holding(document:)
    return nil unless document[:holdings_1display]

    JSON.parse(document[:holdings_1display])&.first&.last
  end

  def call_number(document:)
    holding = first_holding(document:)
    return nil unless holding

    holding['call_number']
  end

  def library(document:)
    holding = first_holding(document:)
    return nil unless holding

    holding['library']
  end

  def solr_fields
    'id,title_display,author_display,pub_created_display,format,holdings_1display'
  end

  def solr_sort
    'score desc, pub_date_start_sort desc, title_sort asc'
  end
end
