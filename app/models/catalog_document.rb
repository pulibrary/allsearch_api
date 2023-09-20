# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the Catalog's JSON
# The document is a Hash
class CatalogDocument < Document
  private

  def id
    document[:id]
  end

  def url
    "https://catalog.princeton.edu/catalog/#{id}"
  end

  def title
    document[:title_display]
  end

  def creator
    document[:author_display]&.first
  end

  def publisher
    document[:pub_created_display]&.first
  end

  def type
    document[:format]&.first
  end

  def description
    # tbd - nothing in the current json that seems relevant
  end

  def doc_keys
    [:call_number, :library]
  end

  def other_fields
    doc_keys.index_with { |key| send(key) }
  end

  def first_holding
    holdings_string = document[:holdings_1display]
    return {} if holdings_string.blank?

    JSON.parse(holdings_string)&.first&.last
  end

  def call_number
    first_holding['call_number']
  end

  def library
    first_holding['library']
  end
end
