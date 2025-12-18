# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
namespace :db do
  # rubocop:enable Metrics/BlockLength

  # Clear Rails default db:migrate task if it exists
  Rake::Task['db:migrate'].clear if Rake::Task.task_defined?('db:migrate')

  desc 'Run ROM/Sequel migrations'
  task :migrate do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!
    Sequel.extension :migration

    unless conn.table_exists?(:schema_migrations)
      conn.create_table(:schema_migrations) do
        column :version, :bigint, null: false, primary_key: true
      end
    end

    migration_dir = File.join(Dir.pwd, 'db', 'rom_migrate')
    applied = conn[:schema_migrations].select_map(:version)

    Dir.glob(File.join(migration_dir, '*.rb')).each do |file|
      version = File.basename(file).split('_').first.to_i

      next if applied.include?(version)

      puts "Applying migration: #{File.basename(file)}"
      load file
      migration = Sequel::Migration.descendants.last
      migration.apply(conn, :up)
      Sequel::Migration.descendants.pop
      conn[:schema_migrations].insert(version: version)
    end

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
    Sequel::Migrator.run(conn, File.join(Dir.pwd, 'db', 'rom_migrate'),
                         target: target,
                         table: :schema_migrations,
                         column: :version)
    puts "Rolled back ROM/Sequel migrations to #{target}."
  end

  desc 'Reset migration tracking table (clears all migration history)'
  task :reset_tracking do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!

    if conn.table_exists?(:schema_migrations)
      conn[:schema_migrations].delete
      puts 'Cleared schema_migrations table'
    else
      puts 'schema_migrations table does not exist'
    end
  end

  desc 'Mark existing migrations as applied without running them (first time setup)'
  task :migrations_applied do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!
    Sequel.extension :migration

    unless conn.table_exists?(:schema_migrations)
      conn.create_table(:schema_migrations) do
        column :version, :bigint, null: false, primary_key: true
      end
    end

    migration_dir = File.join(Dir.pwd, 'db', 'rom_migrate')
    migration_files = Dir.glob(File.join(migration_dir, '*.rb')).map { |f| File.basename(f).split('_').first.to_i }.sort

    migration_files.each do |version|
      if conn[:schema_migrations].where(version: version).any?
        puts "Already applied: #{version}"
      else
        conn[:schema_migrations].insert(version: version)
        puts "Applied: #{version}"
      end
    end

    puts 'All existing migrations are applied.'
  end
end
