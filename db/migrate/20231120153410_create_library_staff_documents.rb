# frozen_string_literal: true

class CreateLibraryStaffDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :library_staff_records do |t|
      t.bigint :puid, null: false
      t.string :netid, null: false
      t.string :phone
      t.string :name, null: false
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :title, null: false
      t.string :library_title, null: false
      t.string :email, null: false
      t.string :section
      t.string :division
      t.string :department, null: false
      t.string :unit
      t.string :office
      t.string :building

      t.timestamps
    end

    add_index :library_staff_records, :first_name, unique: false
    add_index :library_staff_records, :middle_name, unique: false
    add_index :library_staff_records, :title, unique: false
    add_index :library_staff_records, :email, unique: true
    add_index :library_staff_records, :department, unique: false
    add_index :library_staff_records, :office, unique: false
    add_index :library_staff_records, :building, unique: false
    add_index :library_staff_records, :section, unique: false
    add_index :library_staff_records, :division, unique: false
    add_index :library_staff_records, :unit, unique: false
  end
end
