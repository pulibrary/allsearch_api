class AddPronounsToLibraryStaffRecord < ActiveRecord::Migration[7.1]
  def change
    add_column :library_staff_records, :pronouns, :string
  end
end
