# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from PULFALight's JSON
class FindingaidsDocument < Document
  include SolrDocument

  private

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
    document[:abstract_ssm]&.first
  end

  def doc_keys
    [:access_restriction, :date, :extent, :repository]
  end

  def repository
    document[:repository_ssm]&.first
  end

  def extent
    document[:extent_ssm]&.to_sentence
  end

  def access_restriction
    document[:accessrestrict_ssm]&.first
  end

  def date
    document[:normalized_date_ssm]&.first
  end
end
