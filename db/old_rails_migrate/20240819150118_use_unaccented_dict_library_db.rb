class UseUnaccentedDictLibraryDb < ActiveRecord::Migration[7.1]
  def up
    remove_column :library_database_records, :searchable, :virtual

    add_column :library_database_records, :searchable, :virtual,
                type: :tsvector,
                as: "setweight(to_tsvector('unaccented_dict', coalesce(name,'')), 'A')    || " \
                    "setweight(to_tsvector('unaccented_dict', coalesce(alt_names_concat,'')), 'B')  || " \
                    "setweight(to_tsvector('unaccented_dict', coalesce(description,'')), 'C') || " \
                    "setweight(to_tsvector('unaccented_dict', coalesce(subjects_concat,'')), 'D') ",
                stored: true
    
    add_index :library_database_records, :searchable,
              using: :gin, name: 'searchable_idx'
  end
  def down
    remove_column :library_database_records, :searchable, :virtual

    add_column :library_database_records, :searchable, :virtual,
                type: :tsvector,
                as: "setweight(to_tsvector('english', coalesce(name,'')), 'A')    || " \
                    "setweight(to_tsvector('english', coalesce(alt_names_concat,'')), 'B')  || " \
                    "setweight(to_tsvector('english', coalesce(description,'')), 'C') || " \
                    "setweight(to_tsvector('english', coalesce(subjects_concat,'')), 'D') ",
                stored: true
    
    add_index :library_database_records, :searchable,
              using: :gin, name: 'searchable_idx'
  end
end
