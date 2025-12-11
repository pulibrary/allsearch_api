# frozen_string_literal: true

# This class is responsible for refreshing the
# best_bet_document table from the canonical
# spreadsheet maintained by librarians
class BestBetLoadingService < CSVLoadingService
  private

  def process_data
    repository.delete
    repository.new_from_csv csv_without_incomplete_rows
  end

  def existing_records
    repository.best_bet_records.count
  end

  # :reek:FeatureEnvy
  # :reek:NilCheck
  def csv_without_incomplete_rows
    csv.filter do { |row| !(row[0].nil? || row[2].nil? || row[3].nil?) }
  end

  def expected_headers
    ['Title', 'Description', 'URL', 'Search Terms', 'Last Update', 'Updated By']
  end

  def uri
    @uri ||= URI.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vSSDYbAmj_SDVK96DJItSsir_PbjMIqe8cBMvBfRIh4fpVzv3aozhCdulrgJXZzwl-fh-lbULMuLZuO/pub?gid=170493948&single=true&output=csv')
  end

  def repository
    @repository ||= BestBetRepository.new(Rails.application.config.rom)
  end
end
