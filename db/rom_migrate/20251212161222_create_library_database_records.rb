
Sequel.migration do
  change do
    create_table(:library_database_records) do
      primary_key :id
      bigint :libguides_id, null: false
      String :name, null: false
      String :description
      column :alt_names, 'text[]'
      String :alt_names_concat
      String :url
      String :friendly_url
      column :subjects, 'text[]'
      String :subjects_concat
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP

      tsvector :searchable,
              generated_always_as: Sequel.lit(
                    "setweight(to_tsvector('english', coalesce(name,'')), 'A')    || " \
                    "setweight(to_tsvector('english', coalesce(alt_names_concat,'')), 'B')  || " \
                    "setweight(to_tsvector('english', coalesce(description,'')), 'C') || " \
                    "setweight(to_tsvector('english', coalesce(subjects_concat,'')), 'D') ",
              )
    end
    add_index :library_database_records, :searchable,
              using: :gin, name: 'searchable_idx'
  end
end
