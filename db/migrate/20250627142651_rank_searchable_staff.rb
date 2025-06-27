class RankSearchableStaff < ActiveRecord::Migration[8.0]
  def up
    # up_searchable_sql = <<~SQL
    #   setweight(to_tsvector('unaccented_dict', coalesce(title, '')), 'A') ||
    #   setweight(to_tsvector('unaccented_dict', coalesce(areas_of_study, '')), 'B') ||
    #   setweight(to_tsvector('unaccented_dict', coalesce(department, '')), 'C') ||
    #   setweight(to_tsvector('unaccented_dict', coalesce(other_entities, '')), 'D')
    # SQL
    title_searchable_sql = <<~SQL
      setweight(to_tsvector('unaccented_dict', coalesce(title, '')), 'A')
    SQL

    department_searchable_sql = <<~SQL
      setweight(to_tsvector('unaccented_dict', coalesce(department, '')), 'B')
    SQL

    change_table :library_staff_records do |t|
      t.virtual(
        :title_searchable,
        type: :tsvector,
        as: title_searchable_sql,
        stored: true
      )
      t.index ["title_searchable"], name: "staff_title_search_idx", using: :gin
      t.virtual(
        :department_searchable,
        type: :tsvector,
        as: department_searchable_sql,
        stored: true
      )
    end
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
      t.remove :title_searchable
      t.remove :department_searchable
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
