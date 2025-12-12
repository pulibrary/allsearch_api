
Sequel.migration do
  change do
    create_table(:flipper_features) do
      primary_key :id
      String :key, null: false
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    add_index :flipper_features, :key, unique: true

    create_table(:flipper_gates) do
      primary_key :id
      String :feature_key, null: false
      String :key, null: false
      column :value, 'text'
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    add_index :flipper_gates, [:feature_key, :key, :value], unique: true, name: 'flipper_gates_feature_key_key_value_idx'
  end
end
