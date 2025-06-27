class RankSearchableStaff < ActiveRecord::Migration[8.0]
  def up
    up_searchable_sql = <<~SQL
      setweight(to_tsvector('unaccented_dict', 
                    coalesce(title, '')), 'A') ||
      setweight(to_tsvector('unaccented_dict', 
                    coalesce(areas_of_study, '')), 'B') ||
      setweight(to_tsvector('unaccented_dict', coalesce(department, '')), 'C') ||
      setweight(to_tsvector('unaccented_dict', coalesce(other_entities, '')), 'D')
    SQL
    test_sql = <<~SQL
        setweight(to_tsvector('unaccented_dict', coalesce(name,'')), 'A')    ||
        setweight(to_tsvector('unaccented_dict', coalesce(alt_names_concat,'')), 'B')  ||
        setweight(to_tsvector('unaccented_dict', coalesce(description,'')), 'C') ||
        setweight(to_tsvector('unaccented_dict', coalesce(subjects_concat,'')), 'D') 
    SQL
    remove_column :library_staff_records, :searchable, :virtual
    add_column :library_staff_records, :searchable, :virtual,
                type: :tsvector, as: up_searchable_sql, stored: true
    add_index :library_staff_records, :searchable,
          using: :gin, name: 'staff_search_idx'
  end

  def down
    down_searchable_sql = <<~SQL
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
