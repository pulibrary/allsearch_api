# frozen_string_literal: true

class LibraryDatabaseLoadingService < CSVLoadingService
  private

  def class_to_load
    LibraryDatabaseRecord
  end

  def data_is_valid?
    csv.readline == %w[id name description alt_names url friendly_url subjects]
  end

  def uri
    @uri ||= URI.parse('https://lib-jobs.princeton.edu/library-databases.csv')
  end
end
