# frozen_string_literal: true

namespace :library_databases do
  desc 'Refresh the library_database_records table with data from libjobs'
  task sync: [:autoload, :database_connection] do
    LibraryDatabaseLoadingService.new(rom_container: ALLSEARCH_ROM).run
  end
end
