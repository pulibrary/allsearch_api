
Sequel.migration do
  change do
    execute <<~SQL
      CREATE TEXT SEARCH CONFIGURATION unaccented_simple_dict ( COPY = simple );
      ALTER TEXT SEARCH CONFIGURATION unaccented_simple_dict ALTER MAPPING FOR hword, hword_part, word WITH unaccent, simple;
    SQL
    create_table(:library_staff_records) do
      primary_key :id
      bigint :puid, null: false
      String :netid, null: false
      String :phone
      String :name, null: false
      String :last_name
      String :first_name
      String :middle_name
      String :title, null: false
      String :library_title, null: false
      String :email, null: false
      String :team
      String :division
      String :department
      String :unit
      String :office
      String :building
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      String :areas_of_study
      String :other_entities
      String :my_scheduler_link
      String :pronouns

      virtual :name_searchable,
              type: :tsvector,
              as: "to_tsvector('public.unaccented_simple_dict', (coalesce(name, '') || ' ' || coalesce(first_name, '') || ' ' || coalesce(middle_name, '') || ' ' || coalesce(last_name, '')))",
              stored: true

      String :bio

      virtual :searchable,
              type: :tsvector,
              as: "to_tsvector('public.unaccented_dict', (coalesce(title, '') || ' ' || coalesce(email, '') || ' ' || coalesce(department, '') || ' ' || coalesce(office, '') || ' ' || coalesce(building, '') || ' ' || coalesce(team, '') || ' ' || coalesce(division, '') || ' ' || coalesce(unit, '') || ' ' || coalesce(areas_of_study, '') || ' ' || coalesce(bio, '') || ' ' || coalesce(other_entities, '')))",
              stored: true
    end

    add_index :library_staff_records, :name_searchable,
              using: :gin, name: 'staff_name_search_idx'

    add_index :library_staff_records, :searchable,
              using: :gin, name: 'staff_search_idx'
  end
end
