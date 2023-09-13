# frozen_string_literal: true

class CatalogDocument < Document
  private

  def id
    @json[:id]
  end

  def url
    "https://catalog.princeton.edu/catalog/#{id}"
  end

  def title
    @json[:title_display]
  end

  def creator
    @json[:author_display]&.first
  end

  def publisher
    @json[:pub_created_display]&.first
  end

  def type
    @json[:format]&.first
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
    return nil unless @json[:holdings_1display]

    JSON.parse(@json[:holdings_1display])&.first&.last
  end

  def call_number
    holding = first_holding
    return nil unless holding

    holding['call_number']
  end

  def library
    holding = first_holding
    return nil unless holding

    holding['library']
  end
end
