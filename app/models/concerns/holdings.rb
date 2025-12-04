# frozen_string_literal: true

require 'dry-monads'

# This module is responsible for dynamically
# creating methods that provide information
# about a catalog document's holdings
module Holdings
  include Dry::Monads[:maybe]

  private

  [:first, :second].each_with_index do |number, index|
    # Create the first_barcode and second_barcode methods
    define_method "#{number}_barcode" do
      send(:"#{number}_physical_holding")&.barcode
    end

    # Create the first_call_number and second_call_number methods
    define_method "#{number}_call_number" do
      send(:"#{number}_physical_holding")&.call_number
    end

    # Create the first_library and second_library methods
    define_method "#{number}_library" do
      send(:"#{number}_physical_holding")&.library
    end

    # Create the first_status and second_status methods
    define_method "#{number}_status" do
      send(:"#{number}_physical_holding")&.status
    end

    # Create the first_physical_holding and second_physical_holding methods
    define_method "#{number}_physical_holding" do
      # First, check to see if we've already stored this in an instance variable
      return instance_variable_get("@#{__method__}") if instance_variable_defined?("@#{__method__}")

      holding(index).bind do |holding|
        Some(instance_variable_set(
               "@#{__method__}",
               PhysicalHolding.new(holding_id: holding.first,
                                   holding_data: holding.last,
                                   document_id: document[:id])
             ))
      end.value_or(nil)
    end
  end

  def holding(index)
    holdings.bind { Maybe(it[index]) }
  end

  def holdings
    @holdings ||= Maybe(document[:holdings_1display]).bind do |raw|
      if raw.empty?
        None()
      else
        Some(JSON.parse(raw).to_a)
      end
    end
  end
end
