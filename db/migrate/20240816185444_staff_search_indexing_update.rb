class StaffSearchIndexingUpdate < ActiveRecord::Migration[7.1]
  def change
    def up
      change_table :library_staff_records do |t|
        change_table :library_staff_records do |t| 
          t.remove :searchable
          t.virtual :searchable, type: :tsvector,
          as: "to_tsvector('english', coalesce(title, '') || ' ' || " \
                        "coalesce(unaccent(first_name), '') || ' ' || " \
                        "coalesce(unaccent(middle_name), '') || ' ' || " \
                        "coalesce(unaccent(last_name), '') || ' ' || " \
                        "coalesce(unaccent(title), '') || ' ' || " \
                        "coalesce(unaccent(email), '') || ' ' || " \
                        "coalesce(unaccent(department), '') || ' ' || " \
                        "coalesce(unaccent(office), '') || ' ' || " \
                        "coalesce(unaccent(building), '') || ' ' || " \
                        "coalesce(unaccent(team), '') || ' ' || " \
                        "coalesce(unaccent(division), '') || ' ' || " \
                        "coalesce(unaccent(unit), '') || ' ' ||" \
                        "coalesce(unaccent(areas_of_study), '') || ' ' || " \
                        "coalesce(unaccent(other_entities), ''))",
                        stored: true
          t.index ["searchable"], name: "staff_search_idx", using: :gin
        end
      end
    end
    def down
      change_table :library_staff_records do |t| 
        t.remove :searchable
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
end
