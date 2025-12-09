# frozen_string_literal: true

# This relation is responsible for providing an API for reading data
# from the library_staff_records database table
class LibraryStaffRelation < ROM::Relation[:sql]
  schema :library_staff_records, infer: true do
    attribute :name_searchable, Types::String
    attribute :searchable, Types::String
  end

  # this method uses placeholders so is not vulnerable
  # bearer:disable ruby_rails_sql_injection
  # rubocop:disable Layout/LineLength
  def query(search_term)
    where(Sequel.lit(
            "name_searchable @@ websearch_to_tsquery('unaccented_simple_dict', ?) OR searchable @@ websearch_to_tsquery('unaccented_dict', ?)", search_term, search_term
          ))
      .reverse(Sequel.lit(
                 "ts_rank(name_searchable, websearch_to_tsquery('unaccented_simple_dict', unaccent(?))) + ts_rank(searchable, websearch_to_tsquery('unaccented_dict', unaccent(?)))", search_term, search_term
               ))
  end
  # rubocop:enable Layout/LineLength

  auto_struct true
end
