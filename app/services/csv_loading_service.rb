# frozen_string_literal: true

require 'csv'
require 'open-uri'

# A general class that can be subclassed
# to load data from a remote CSV file
# into the database
class CSVLoadingService
  def run
    fetch_data
    process_data if data_is_valid?
  end

  private

  attr_reader :csv

  def fetch_data
    contents = uri.open
    @csv = CSV.new(contents)
  end

  def process_data
    class_to_load.destroy_all
    csv.each { |row| class_to_load.new_from_csv(row) }
  end

  def data_is_valid?
    false
  end

  # If the CSV shrinks by 25% or more, assume something is wrong
  def csv_is_much_smaller?
    existing_records = class_to_load.count
    csv_shrinkage = existing_records - csv.readlines.size
    csv.rewind
    csv_shrinkage > (existing_records * 0.25)
  end

  def uri; end

  def class_to_load; end
end
