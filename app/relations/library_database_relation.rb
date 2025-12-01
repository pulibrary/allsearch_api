# frozen_string_literal: true

class LibraryDatabaseRelation < ROM::Relation[:sql]
  schema :library_database_records, infer: true do
    attribute :searchable, Types::String
  end
end
