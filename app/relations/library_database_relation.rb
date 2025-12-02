# frozen_string_literal: true

# This relation is responsible for providing an API for reading data
# from the library_database_records database table
class LibraryDatabaseRelation < ROM::Relation[:sql]
  schema :library_database_records, infer: true do
    attribute :searchable, Types::String
  end

  # this method uses placeholders so is not vulnerable
  # bearer:disable ruby_rails_sql_injection
  def query(search_term)
    where(Sequel.lit("searchable @@ websearch_to_tsquery('unaccented_dict', unaccent(?))", search_term))
      .reverse(Sequel.lit("ts_rank(searchable, websearch_to_tsquery('unaccented_dict', unaccent(?)))", search_term))
  end

  auto_struct true
end
