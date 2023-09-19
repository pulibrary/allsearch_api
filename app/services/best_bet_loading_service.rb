# frozen_string_literal: true

require 'csv'
require 'open-uri'

# This class is responsible for refreshing the
# best_bet_document table from the canonical
# spreadsheet maintained by librarians
class BestBetLoadingService
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
    BestBetRecord.destroy_all
    csv.each { |row| BestBetRecord.new_from_csv(row) }
  end

  def data_is_valid?
    csv.readline == ['Title', 'Description', 'URL', 'Search Terms', 'Last Update']
  end

  def uri
    @uri ||= URI.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vSSDYbAmj_SDVK96DJItSsir_PbjMIqe8cBMvBfRIh4fpVzv3aozhCdulrgJXZzwl-fh-lbULMuLZuO/pub?gid=170493948&single=true&output=csv')
  end
end
