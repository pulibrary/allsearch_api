class AddUnaccentedSimpleDictionary < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL
      CREATE TEXT SEARCH CONFIGURATION unaccented_simple_dict ( COPY = simple );
      ALTER TEXT SEARCH CONFIGURATION unaccented_simple_dict ALTER MAPPING FOR hword, hword_part, word WITH unaccent, simple;
    SQL
  end
  def down
    execute <<~SQL
      DROP TEXT SEARCH CONFIGURATION IF EXISTS unaccented_simple_dict;
    SQL
  end
end
