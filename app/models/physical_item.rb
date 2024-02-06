# frozen_string_literal: true

# This class is repsonsible for recording the
# status and other characteristics of a physical
# item

class PhysicalItem
  def initialize(item:)
    @item = item
  end

  def in_place?
    item['status_at_load'] == '1' && item['process_type'].blank?
  end

  def barcode
    item['barcode']
  end

  private

  attr_accessor :item
end
