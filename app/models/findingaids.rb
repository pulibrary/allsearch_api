# frozen_string_literal: true

class Findingaids
  include ActiveModel::API
  include Parsed
  include Solr
  attr_reader :query_terms, :service, :service_response

  def initialize(query_terms:)
    @query_terms = query_terms
    @service = 'findingaids'
    @service_response = solr_service_response(query_terms:)
  end

  # Use the collection name as the title?
  def title(document:)
    document[:collection_ssm]&.first
  end

  def creator(document:)
    document[:creator_ssm]&.first
  end

  # No sensible field to map to this currently
  def publisher(document:)
    # tbd - nothing in the current json that seems relevant
  end

  def type(document:)
    document[:level_sim]&.first
  end

  # This field may contain html
  def description(document:)
    document[:scopecontent_ssm]&.first
  end

  def other_fields(document:)
    doc_keys = [:repository, :extent, :access_restriction]
    parsed_record(document:, doc_keys:)
  end

  def repository(document:)
    document[:repository_ssm]&.first
  end

  def extent(document:)
    document[:extent_ssm]&.to_sentence
  end

  def access_restriction(document:)
    document[:accessrestrict_ssm]&.first
  end

  def solr_collection
    'pulfalight-production'
  end

  def solr_fields
    'id,collection_ssm,creator_ssm,level_sim,scopecontent_ssm,repository_ssm,extent_ssm,accessrestrict_ssm'
  end

  def solr_sort
    'score desc, title_sort asc'
  end

  def extra_solr_params
    '&fq=level_sim:Collection'
  end
end
