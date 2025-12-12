# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :rom do
  # rubocop:enable Metrics/BlockLength

  desc 'Run ROM/Sequel migrations'
  task :migrate do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!
    Sequel.extension :migration
    Sequel::Migrator.run(conn, File.join(Dir.pwd, 'db', 'rom_migrate'), table: :sequel_schema_migrations)
    puts 'ROM/Sequel migrations run.'
  end

  desc 'Rollback ROM/Sequel migrations to a target (provide TARGET=timestamp)'
  task :rollback do
    require_relative '../../init/rom_factory'

    target = ENV['TARGET']&.to_i
    unless target&.positive?
      puts 'Please provide TARGET=timestamp to rollback to (e.g. TARGET=20251211000001)'
      exit 1
    end

    conn = RomFactory.new.database_if_available.value!
    Sequel.extension :migration
    Sequel::Migrator.run(conn, File.join(Dir.pwd, 'db', 'rom_migrate'), target: target,
                                                                        table: :sequel_schema_migrations)
    puts "Rolled back ROM/Sequel migrations to #{target}."
  end

  desc 'Mark existing migrations as applied without running them (first time setup)'
  task :migrations_applied do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!
    Sequel.extension :migration

    unless conn.table_exists?(:sequel_schema_migrations)
      conn.create_table(:sequel_schema_migrations) do
        column :filename, String, null: false, primary_key: true
      end
    end

    migration_dir = File.join(Dir.pwd, 'db', 'rom_migrate')
    migration_files = Dir.glob(File.join(migration_dir, '*.rb')).map { |f| File.basename(f) }.sort

    migration_files.each do |filename|
      if conn[:sequel_schema_migrations].where(filename: filename).any?
        puts "Already applied: #{filename}"
      else
        conn[:sequel_schema_migrations].insert(filename: filename)
        puts "Applied: #{filename}"
      end
    end

    puts 'All existing migrations are applied.'
  end

  desc 'Reset migration tracking table (clears all migration history)'
  task :reset_tracking do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!

    if conn.table_exists?(:sequel_schema_migrations)
      conn[:sequel_schema_migrations].delete
      puts 'Cleared sequel_schema_migrations table'
    else
      puts 'sequel_schema_migrations table does not exist'
    end
  end
end
