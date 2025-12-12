
Sequel.migration do
  change do
    create_table(:oauth_tokens) do
      primary_key :id
      String :service, null: false
      String :endpoint, null: false
      String :token, null: true
      DateTime :expiration_time, null: true
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
    add_index :oauth_tokens, :service, unique: true
    add_index :oauth_tokens, :endpoint, unique: true
  end
end
