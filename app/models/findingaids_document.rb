# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from PULFALight's JSON
class FindingaidsDocument < Document
  include SolrDocument

  def initialize(document:, doc_keys:, allsearch_config: ALLSEARCH_CONFIGS[:allsearch])
    super(document:, doc_keys:)
    @allsearch_config = allsearch_config
  end

  private

  attr_reader :allsearch_config

  def service
    'findingaids'
  end

  # Use the collection name as the title?
  def title
    document[:collection_ssm]&.first
  end

  def creator
    document[:creator_ssm]&.first
  end

  # No sensible field to map to this currently
  def publisher
    # tbd - nothing in the current json that seems relevant
  end

  def type
    document[:level_ssm]&.first
  end

  # This field may contain html
  def description
    sanitize document[:abstract_ssm]&.first
  end

  def doc_keys
    [:access_restriction, :date, :extent, :repository]
  end

  def repository
    document[:repository_ssm]&.first
  end

  def extent
    Sentence.new(document[:extent_ssm]).call
  end

  def access_restriction
    document[:accessrestrict_ssm]&.first
  end

  def date
    document[:normalized_date_ssm]&.first
  end
end
