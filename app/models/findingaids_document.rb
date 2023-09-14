# frozen_string_literal: true

class FindingaidsDocument < Document
  private

  def id
    @json[:id]
  end

  def url
    "https://findingaids.princeton.edu/catalog/#{id}"
  end

  # Use the collection name as the title?
  def title
    @json[:collection_ssm]&.first
  end

  def creator
    @json[:creator_ssm]&.first
  end

  # No sensible field to map to this currently
  def publisher
    # tbd - nothing in the current json that seems relevant
  end

  def type
    @json[:level_sim]&.first
  end

  # This field may contain html
  def description
    @json[:scopecontent_ssm]&.first
  end

  def doc_keys
    [:repository, :extent, :access_restriction]
  end

  def repository
    @json[:repository_ssm]&.first
  end

  def extent
    @json[:extent_ssm]&.to_sentence
  end

  def access_restriction
    @json[:accessrestrict_ssm]&.first
  end
end
