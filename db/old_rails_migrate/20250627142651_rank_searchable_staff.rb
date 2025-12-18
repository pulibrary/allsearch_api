class RankSearchableStaff < ActiveRecord::Migration[8.0]
  def up
    up_searchable_sql = <<~SQL.squish
      to_tsvector('unaccented_dict', 
                    coalesce(title, '') || ' ' || 
                    coalesce(email, '') || ' ' || 
                    coalesce(department, '') || ' ' || 
                    coalesce(office, '') || ' ' || 
                    coalesce(building, '') || ' ' || 
                    coalesce(team, '') || ' ' || 
                    coalesce(division, '') || ' ' || 
                    coalesce(unit, '') || ' ' ||
                    coalesce(areas_of_study, '') || ' ' || 
                    coalesce(bio, '') || ' ' ||
                    coalesce(other_entities, ''))
    SQL
    remove_column :library_staff_records, :searchable, :virtual
    add_column :library_staff_records, :bio, :string
    add_column :library_staff_records, :searchable, :virtual,
                type: :tsvector, as: up_searchable_sql, stored: true
    add_index :library_staff_records, :searchable,
          using: :gin, name: 'staff_search_idx'
  end

  def down
    down_searchable_sql = <<~SQL.squish
      to_tsvector('unaccented_dict', 
                    coalesce(title, '') || ' ' || 
                    coalesce(email, '') || ' ' || 
                    coalesce(department, '') || ' ' || 
                    coalesce(office, '') || ' ' || 
                    coalesce(building, '') || ' ' || 
                    coalesce(team, '') || ' ' || 
                    coalesce(division, '') || ' ' || 
                    coalesce(unit, '') || ' ' ||
                    coalesce(areas_of_study, '') || ' ' || 
                    coalesce(other_entities, ''))
    SQL
    change_table :library_staff_records do |t|
      t.remove :searchable
      t.remove :bio
      t.virtual(
        :searchable,
        type: :tsvector,
        as: down_searchable_sql,
        stored: true
      )
      t.index ["searchable"], name: "staff_search_idx", using: :gin
    end
  end
end
