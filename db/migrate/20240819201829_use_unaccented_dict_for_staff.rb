class UseUnaccentedDictForStaff < ActiveRecord::Migration[7.1]
  def up
    remove_column :library_staff_records, :searchable, :virtual

    add_column :library_staff_records, :searchable, :virtual, type: :tsvector, 
               as: "to_tsvector('unaccented_dict', coalesce(title, '') || ' ' || " \
                   "coalesce(first_name, '') || ' ' || " \
                   "coalesce(middle_name, '') || ' ' || " \
                   "coalesce(last_name, '') || ' ' || " \
                   "coalesce(title, '') || ' ' || " \
                   "coalesce(email, '') || ' ' || " \
                   "coalesce(department, '') || ' ' || " \
                   "coalesce(office, '') || ' ' || " \
                   "coalesce(building, '') || ' ' || " \
                   "coalesce(team, '') || ' ' || " \
                   "coalesce(division, '') || ' ' || " \
                   "coalesce(unit, '') || ' ' ||" \
                   "coalesce(areas_of_study, '') || ' ' || " \
                   "coalesce(other_entities, ''))",
                   stored: true

    add_index :library_staff_records, :searchable, using: :gin, name: "staff_search_idx"
  end

  def down
    remove_column :library_staff_records, :searchable, :virtual

    change_table :library_staff_records do |t| 
      t.virtual :searchable, type: :tsvector,
      as: "to_tsvector('english', coalesce(title, '') || ' ' || " \
                    "coalesce(first_name, '') || ' ' || " \
                    "coalesce(middle_name, '') || ' ' || " \
                    "coalesce(last_name, '') || ' ' || " \
                    "coalesce(title, '') || ' ' || " \
                    "coalesce(email, '') || ' ' || " \
                    "coalesce(department, '') || ' ' || " \
                    "coalesce(office, '') || ' ' || " \
                    "coalesce(building, '') || ' ' || " \
                    "coalesce(team, '') || ' ' || " \
                    "coalesce(division, '') || ' ' || " \
                    "coalesce(unit, '') || ' ' ||" \
                    "coalesce(areas_of_study, '') || ' ' || " \
                    "coalesce(other_entities, ''))",
                    stored: true
      t.index ["searchable"], name: "staff_search_idx", using: :gin
    end
  end
end
