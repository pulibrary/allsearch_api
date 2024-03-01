# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from the Catalog's JSON
# The document is a Hash
class CatalogDocument < Document
  private

  include Holdings

  def id
    document[:id]
  end

  def url
    "https://#{service_subdomain}.princeton.edu/catalog/#{id}"
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
    [:first_barcode, :second_barcode, :first_call_number, :second_call_number, :first_library, :second_library,
     :first_status, :second_status, :resource_url, :resource_url_label]
  end

  def resource_url
    portfolio['url'] || electronic_access&.keys&.first
  end

  def resource_url_label
    return unless should_display_resource_url_label?

    portfolio['title'] || electronic_access&.values&.first&.first || 'Online content'
  end

  def should_display_resource_url_label?
    portfolio.present? || electronic_access.present?
  end

  def portfolio
    @portfolio ||= begin
      portfolio_string = document[:electronic_portfolio_s]&.first
      portfolio_string.present? ? JSON.parse(portfolio_string) : {}
    end
  end

  def electronic_access
    @electronic_access ||= begin
      electronic_access_string = document[:electronic_access_1display]
      electronic_access_string.present? ? JSON.parse(electronic_access_string) : {}
    end
  end

  def service_subdomain
    Rails.application.config_for(:allsearch)['catalog'][:subdomain]
  end
end
