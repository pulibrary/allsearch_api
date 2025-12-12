
Sequel.migration do
  change do
    create_table(:best_bet_records) do
      primary_key :id
      String :title
      String :description
      String :url
      column :search_terms, 'text[]'
      Date :last_update
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
