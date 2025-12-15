# frozen_string_literal: true

class LibraryDatabaseLoadingService < CSVLoadingService
  private

  def process_data
    repository.delete
    repository.create_from_csv csv
  end

  def existing_records
    repository.library_database_records.count
  end

  def expected_headers
    %w[id name description alt_names url friendly_url subjects]
  end

  def uri
    @uri ||= URI.parse('https://lib-jobs.princeton.edu/library-databases.csv')
  end

  def repository
    @repository ||= repository_factory.library_database
  end

  def repository_factory
    @repository_factory ||= RepositoryFactory.new(rom_container)
  end
end
