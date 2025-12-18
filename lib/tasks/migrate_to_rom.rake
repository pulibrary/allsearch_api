# frozen_string_literal: true

namespace :db do
  desc 'One-time task: Convert Rails schema_migrations to ROM format'
  task :migrate_to_rom do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!

    # Check if version column is string type (Rails format)
    column_type = conn.schema(:schema_migrations).find { |col| col[0] == :version }&.dig(1, :db_type)

    if column_type == 'character varying'
      puts 'Converting schema_migrations from Rails format to ROM format...'

      # Clear old Rails migrations
      conn[:schema_migrations].delete

      # Change column type from varchar to bigint
      conn.alter_table(:schema_migrations) do
        set_column_type :version, :bigint
      end

      puts 'Populating ROM migrations...'
      Rake::Task['db:migrations_applied'].invoke

      puts 'Migration to ROM complete!'
    else
      puts 'Already using ROM format, running normal migrations...'
      Rake::Task['db:migrate'].invoke
    end
  end
end
