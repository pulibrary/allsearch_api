# frozen_string_literal: true

class DpulDocument < Document
  private

  def id
    @json[:id]
  end

  def url
    "https://dpul.princeton.edu/catalog/#{id}"
  end

  def title
    @json[:readonly_title_ssim]&.first
  end

  def creator
    @json[:readonly_creator_ssim]&.first
  end

  def publisher
    @json[:readonly_publisher_ssim]&.first
  end

  def type
    @json[:readonly_format_ssim]&.first
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
    @json[:readonly_collections_tesim]&.first
  end
end
