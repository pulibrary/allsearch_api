# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from DPUL's JSON
class DpulDocument < Document
  private

  def id
    document[:id]
  end

  def url
    "https://#{service_subdomain}.princeton.edu/catalog/#{id}"
  end

  def title
    document[:readonly_title_ssim]&.first
  end

  def creator
    document[:readonly_creator_ssim]&.first
  end

  def publisher
    document[:readonly_publisher_ssim]&.first
  end

  def type
    document[:readonly_format_ssim]&.first
  end

  def description
    # tbd - nothing in the current json that seems relevant
  end

  def doc_keys
    [:collection]
  end

  def collection
    document[:readonly_collections_tesim]&.first
  end

  def service_subdomain
    Rails.application.config_for(:allsearch)['dpul'][:subdomain]
  end
end
