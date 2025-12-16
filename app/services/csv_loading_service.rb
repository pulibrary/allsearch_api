# frozen_string_literal: true

require 'csv'
require 'open-uri'
require allsearch_path 'init/logger'

# A general class that can be subclassed
# to load data from a remote CSV file
# into the database
class CSVLoadingService
  # :reek:ControlParameter - once we remove Rails, we can replace the default in the signature with
  # rom_container: ALLSEARCH_ROM and remove the offending line
  def initialize(logger: ALLSEARCH_LOGGER, rom_container: nil)
    @logger = logger
    @rom_container = rom_container || Rails.application.config&.rom || RomFactory.new.require_rom!
  end

  def run
    fetch_data
    process_data if data_is_valid?
  end

  private

  attr_reader :csv, :logger, :rom_container

  def fetch_data
    contents = uri.open
    @csv = CSV.new(contents)
  end

  # Data is valid if the CSV has not shrunk significantly, and the header row matches the expected headers
  def data_is_valid?
    return false if csv_is_much_smaller?

    header_row_matches?
  end

  # If the CSV shrinks by 25% or more, assume something is wrong
  def csv_is_much_smaller?
    much_smaller = csv_shrinkage > (existing_records * 0.25)
    return false unless much_smaller

    logger.error("The #{self.class} had a much shorter CSV. " \
                 "The original length was #{existing_records} rows, " \
                 "the new length is #{new_csv_length} rows.")
    much_smaller
  end

  def csv_shrinkage
    existing_records - new_csv_length
  end

  def new_csv_length
    @new_csv_length ||= begin
      length = csv.readlines.size
      csv.rewind
      length
    end
  end

  # Expect certain headers
  def header_row_matches?
    new_headers = csv.readline
    return true if (new_headers & expected_headers) == expected_headers

    logger.error("The #{self.class} did not load the CSV " \
                 "because the headers didn't match. The expected headers are: " \
                 "#{expected_headers.to_sentence}. " \
                 "The new CSV headers are #{new_headers&.to_sentence}.")
    false
  end

  def uri; end

  def class_to_load; end
end
