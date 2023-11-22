class StaffSearchIndexing < ActiveRecord::Migration[7.1]
  def change
    remove_index :library_staff_records, :first_name
    remove_index :library_staff_records, :middle_name
    remove_index :library_staff_records, :title
    remove_index :library_staff_records, :email
    remove_index :library_staff_records, :department
    remove_index :library_staff_records, :office
    remove_index :library_staff_records, :building
    remove_index :library_staff_records, :section
    remove_index :library_staff_records, :division
    remove_index :library_staff_records, :unit

    add_column :library_staff_records, :searchable, :virtual,
                type: :tsvector,
                as: "to_tsvector('english', coalesce(title, '') || ' ' || " \
                    "coalesce(first_name, '') || ' ' || " \
                    "coalesce(middle_name, '') || ' ' || " \
                    "coalesce(last_name, '') || ' ' || " \
                    "coalesce(title, '') || ' ' || " \
                    "coalesce(email, '') || ' ' || " \
                    "coalesce(department, '') || ' ' || " \
                    "coalesce(office, '') || ' ' || " \
                    "coalesce(building, '') || ' ' || " \
                    "coalesce(section, '') || ' ' || " \
                    "coalesce(division, '') || ' ' || " \
                    "coalesce(unit, ''))",
                stored: true
    add_index :library_staff_records, :searchable,
               using: :gin, name: 'staff_search_idx'
  end
end
