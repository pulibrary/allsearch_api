# frozen_string_literal: true

namespace :library_staff do
    desc 'Refresh the library_staff_documents table with data from lib-jobs'
    task sync: :environment do
      LibraryStaffLoadingService.new.run
    end
  end
