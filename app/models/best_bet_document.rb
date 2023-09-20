# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the BestBetRecords in the database
# The document is a BestBetRecord
class BestBetDocument < Document
  private

  def title
    document.title
  end

  # Not relevant for this service
  def creator; end

  # TODO: Would it be possible to add this to the sheet? or is it irrelevant?
  def publisher; end

  # TODO: Could we add identifiers to the sheet? Then they would be more likely to stay consistent
  def id
    document.id
  end

  # TODO: Can we add this to the sheet? Or should they all be "Electronic Resource" or similar?
  def type
    'Electronic Resource'
  end

  def description
    document.description
  end

  def url
    document.url
  end

  # No other fields needed at this time
  def other_fields; end
end
