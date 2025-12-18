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

      # Truncate table
      conn.run('TRUNCATE TABLE schema_migrations')

      # Change column type from varchar to bigint with explicit casting
      conn.run('ALTER TABLE schema_migrations ALTER COLUMN version TYPE bigint USING version::bigint')

      puts 'Populating ROM migrations...'
      Rake::Task['db:migrations_applied'].invoke

      puts 'Migration to ROM complete!'
    else
      puts 'Already using ROM format, running normal migrations...'
      Rake::Task['db:migrate'].invoke
    end
  end
end
