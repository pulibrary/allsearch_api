# frozen_string_literal: true

require 'benchmark/ips'
require_relative '../config/environment'

Benchmark.ips do |b|
  library_database_repo = LibraryDatabaseRepository.new Rails.application.config.rom
  csv = CSV.read Rails.root.join('spec/fixtures/files/libjobs/library-databases.csv'), headers: true
  b.report('LibraryDatabaseRepository#create_from_csv') do
    library_database_repo.create_from_csv csv
    # The deletion should ideally be excluded from the benchmark; it is not what we are trying to measure,
    # but I am not sure how to do that
    library_database_repo.delete
  end
end
