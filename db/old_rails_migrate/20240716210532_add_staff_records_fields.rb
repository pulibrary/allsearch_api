class AddStaffRecordsFields < ActiveRecord::Migration[7.1]
  
  def up
    change_table :library_staff_records do |t|
      t.column :areas_of_study, :string
      t.column :other_entities, :string
      t.column :my_scheduler_link, :string
      t.rename :section, :team
    end  
  end
  def down
    change_table :library_staff_records do |t|
      t.remove :areas_of_study
      t.remove :other_entities
      t.remove :my_scheduler_link
      t.rename :team, :section
    end
  end  
   
end
