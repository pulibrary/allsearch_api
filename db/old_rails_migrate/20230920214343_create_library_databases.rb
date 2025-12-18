# frozen_string_literal: true

class CreateLibraryDatabases < ActiveRecord::Migration[7.0]
  def change
    create_table :library_database_records do |t|
      t.bigint :libguides_id, null: false
      t.string :name, null: false
      t.string :description
      t.string :alt_names, array: true
      t.string :alt_names_concat
      t.string :url
      t.string :friendly_url
      t.string :subjects, array: true
      t.string :subjects_concat

      t.virtual :searchable,
                type: :tsvector,
                as: "to_tsvector('english', coalesce(name, '') || ' ' || " \
                    "coalesce(alt_names_concat, '') || ' ' || " \
                    "coalesce(description, '') || ' ' || " \
                    "coalesce(subjects_concat, ''))",
                stored: true

      t.timestamps
    end
    add_index :library_database_records, :searchable,
              using: :gin, name: 'searchable_idx'
  end
end
