# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from DPUL's JSON
class DpulDocument < Document
  private

  def id
    document[:id]
  end

  def url
    "https://dpul.princeton.edu/catalog/#{id}"
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

  def other_fields
    doc_keys.index_with { |key| send(key) }
  end

  def collection
    document[:readonly_collections_tesim]&.first
  end
end
