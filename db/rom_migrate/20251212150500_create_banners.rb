
Sequel.migration do
  change do
    create_table(:banners) do
      primary_key :id
      String :text, text: true, default: ''
      Boolean :display_banner, default: false
      Integer :alert_status, default: 1
      Boolean :dismissible, default: true
      Boolean :autoclear, default: false
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
