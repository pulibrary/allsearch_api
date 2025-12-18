# frozen_string_literal: true

namespace :db do
  desc 'One-time task: Clear Rails migrations and apply ROM migrations'
  task :migrate_to_rom do
    require_relative '../../init/rom_factory'

    conn = RomFactory.new.database_if_available.value!

    puts 'Clearing old Rails migrations from schema_migrations...'
    conn[:schema_migrations].delete

    puts 'Running ROM migrations...'
    Rake::Task['db:migrate'].invoke

    puts 'Migration to ROM complete!'
  end
end
