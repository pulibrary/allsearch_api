# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the BestBetRecords in the database
class BestBetDocument < Document
  private

  def title
    json.title
  end

  # Not relevant for this service
  def creator; end

  # TODO: Would it be possible to add this to the sheet? or is it irrelevant?
  def publisher; end

  # TODO: Could we add identifiers to the sheet? Then they would be more likely to stay consistent
  def id
    json.id
  end

  # TODO: Can we add this to the sheet? Or should they all be "Electronic Resource" or similar?
  def type
    'Electronic Resource'
  end

  def description
    json.description
  end

  def url
    json.url
  end

  # No other fields needed at this time
  def other_fields; end
end
