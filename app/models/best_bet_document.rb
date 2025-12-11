# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the BestBetRecords in the database
# The document is a BestBetRecord
class BestBetDocument
  def initialize(attributes)
    @attributes = attributes
  end

  def public_metadata
    {
      title:,
      id:,
      description:,
      url:,
      type: 'Electronic Resource'
    }.compact
  end

  private

  attr_reader :attributes

  def title
    @attributes[:title]
  end

  # TODO: Could we add identifiers to the sheet? Then they would be more likely to stay consistent
  def id
    @attributes[:id]
  end

  def description
    @attributes[:description]
  end

  def url
    @attributes[:url]
  end

end
