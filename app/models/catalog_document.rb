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
    [:call_number, :library, :resource_url]
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

  def resource_url
    portfolio_string = document[:electronic_portfolio_s]&.first
    electronic_access = document[:electronic_access_1display]
    if portfolio_string.present?
      JSON.parse(portfolio_string)['url']
    elsif electronic_access.present?
      JSON.parse(electronic_access)&.keys&.first
    end
  end
end
