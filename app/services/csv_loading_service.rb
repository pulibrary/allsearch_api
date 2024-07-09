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

  # Data is valid if the CSV has not shrunk significantly, and the header row matches the expected headers
  def data_is_valid?
    return false if csv_is_much_smaller?

    header_row_matches?
  end

  # If the CSV shrinks by 25% or more, assume something is wrong
  def csv_is_much_smaller?
    existing_records = class_to_load.count
    new_csv_length = csv.readlines.size
    csv_shrinkage = existing_records - new_csv_length
    csv.rewind
    much_smaller = csv_shrinkage > (existing_records * 0.25)
    return false unless much_smaller

    Rails.logger.error("The #{self.class} had a much shorter CSV. " \
                       "The original length was #{existing_records} rows, " \
                       "the new length is #{new_csv_length} rows.")
    much_smaller
  end

  # Expect certain headers
  def header_row_matches?
    return true if csv.readline == expected_headers

    Rails.logger.error("The #{self.class} did not load the CSV " \
                       "because the headers didn't match. The expected headers are: " \
                       "#{expected_headers.to_sentence}. " \
                       "The new CSV headers are #{csv.readline&.to_sentence}.")
    false
  end

  def uri; end

  def class_to_load; end
end
