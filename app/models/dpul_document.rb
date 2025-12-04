# frozen_string_literal: true

# This class is responsible for getting relevant
# metadata from DPUL's JSON
class DpulDocument < Document
  include SolrDocument

  def initialize(document:, doc_keys:, environment: Environment.new)
    super(document:, doc_keys:)
    @environment = environment
  end

  private

  attr_reader :environment

  def service
    'dpul'
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
end
