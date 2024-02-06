# frozen_string_literal: true

# This class is responsible for determining
# the status of a physical holding in the ILS
class PhysicalHolding
  def initialize(holding_id:, holding_data:, document_id:)
    @holding_id = holding_id
    @holding_data = holding_data
    @document_id = document_id
  end

  def barcode
    items&.first&.barcode
  end

  def call_number
    @holding_data['call_number']
  end

  def library
    @library ||= @holding_data['library']
  end

  def status
    return unless library

    if coin? || senior_thesis?
      'On-site access'
    elsif alma_temporary_location_status
      alma_temporary_location_status
    elsif alma_location_status
      alma_location_status
    end
  end

  private

  attr_accessor :document_id

  def alma?
    document_id.start_with?('99') && document_id.end_with?('6421')
  end

  def coin?
    document_id.start_with? 'coin-'
  end

  def senior_thesis?
    document_id.start_with? 'dsp'
  end

  def alma_temporary_location_status
    # temporary location holdings have an alphabetical holding id
    return unless alma? && @holding_id.match(/[a-zA-Z]\$[a-zA-Z]/)

    @holding_id == 'RES_SHARE$IN_RS_REQ' ? 'Unavailable' : 'View record for Full Availability'
  end

  def alma_location_status
    return unless alma?

    if items_in_place_count == items&.count
      'Available'
    elsif items_in_place_count.zero?
      'Unavailable'
    elsif items_in_place_count < items&.count
      'Some items not available'
    end
  end

  def items
    @items ||= @holding_data['items']&.map { |item| PhysicalItem.new item: } || []
  end

  def items_in_place_count
    items&.count(&:in_place?)
  end
end
