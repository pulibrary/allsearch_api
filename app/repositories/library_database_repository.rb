# frozen_string_literal: true

require 'rom-repository'

class LibraryDatabaseRepository < ROM::Repository[:library_database_records]
  commands :create,
           use: :timestamps,
           plugins_options: { timestamps: { timestamps: [:created_at, :updated_at] } }
end
