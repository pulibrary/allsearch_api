# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../config/environment'
require_relative '../app/paths'

Benchmark.ips do |b|
  library_database_repo = RepositoryFactory.library_database
  csv = CSV.read allsearch_path('spec/fixtures/files/libjobs/library-databases.csv'), headers: true
  b.report('LibraryDatabaseRepository#create_from_csv') do
    library_database_repo.create_from_csv csv
    # The deletion should ideally be excluded from the benchmark; it is not what we are trying to measure,
    # but I am not sure how to do that
    library_database_repo.delete
  end
end

Benchmark.ips do |b|
  library_staff_repo = RepositoryFactory.library_staff
  csv = CSV.read Rails.root.join('spec/fixtures/files/library_staff/staff-directory.csv'), headers: true
  b.report('LibraryStaffRepository#new_from_csv') do
    library_staff_repo.new_from_csv csv
    # The deletion should ideally be excluded from the benchmark; it is not what we are trying to measure,
    # but I am not sure how to do that
    library_staff_repo.delete
  end
end
