# frozen_string_literal: true

namespace :library_staff do
  desc 'Refresh the library_staff_documents table with data from lib-jobs'
  task sync: [:autoload, :database_connection] do
    LibraryStaffLoadingService.new(rom_container: ALLSEARCH_ROM).run
  end
end
