# frozen_string_literal: true

namespace :library_databases do
  desc 'Refresh the library_database_records table with data from libjobs'
  task sync: :environment do
    LibraryDatabaseLoadingService.new.run
  end
end
