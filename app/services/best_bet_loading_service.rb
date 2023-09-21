# frozen_string_literal: true

# This class is responsible for refreshing the
# best_bet_document table from the canonical
# spreadsheet maintained by librarians
class BestBetLoadingService < CSVLoadingService
  private

  def class_to_load
    BestBetRecord
  end

  def data_is_valid?
    csv.readline == ['Title', 'Description', 'URL', 'Search Terms', 'Last Update']
  end

  def uri
    @uri ||= URI.parse('https://docs.google.com/spreadsheets/d/e/2PACX-1vSSDYbAmj_SDVK96DJItSsir_PbjMIqe8cBMvBfRIh4fpVzv3aozhCdulrgJXZzwl-fh-lbULMuLZuO/pub?gid=170493948&single=true&output=csv')
  end
end
