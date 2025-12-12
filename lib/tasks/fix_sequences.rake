# frozen_string_literal: true

namespace :rom do
  desc 'Fix missing sequences for primary keys'
  task :fix_sequences do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!

    tables = [:best_bet_records, :oauth_tokens, :library_databases, :library_staff_documents, :banners]

    tables.each do |table|
      next unless conn.table_exists?(table)

      sequence_name = "#{table}_id_seq"

      conn.run("CREATE SEQUENCE IF NOT EXISTS #{sequence_name}")

      conn.run("ALTER TABLE #{table} ALTER COLUMN id SET DEFAULT nextval('#{sequence_name}')")

      conn.run("SELECT setval('#{sequence_name}', (SELECT COALESCE(MAX(id), 0) + 1 FROM #{table}))")

      puts "Fixed sequence for #{table}"
    end

    puts 'All sequences fixed.'
  end
end
