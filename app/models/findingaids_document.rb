# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from PULFALight's JSON
class FindingaidsDocument < Document
  private

  def id
    document[:id]
  end

  def url
    "https://findingaids.princeton.edu/catalog/#{id}"
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
    document[:level_sim]&.first
  end

  # This field may contain html
  def description
    document[:scopecontent_ssm]&.first
  end

  def doc_keys
    [:repository, :extent, :access_restriction]
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
end
