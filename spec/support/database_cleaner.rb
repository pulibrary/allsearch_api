# frozen_string_literal: true

require 'database_cleaner/sequel'
require_relative '../../app/paths'
require allsearch_path 'db/seeds'
require allsearch_path 'config/environment'
require allsearch_path 'init/rom_factory'

RSpec.configure do |config|
  rom = if Rails.application.config.respond_to?(:rom) && Rails.application.config.rom
          Rails.application.config.rom
        else
          RomFactory.new.require_rom!
        end
  all_databases = rom.gateways.values.map(&:connection)

  config.before :suite do
    all_databases.each do |db|
      DatabaseCleaner[:sequel, db: db].clean_with :truncation, except: ['schema_migrations']
      create_banner_if_none_exists
    end

    config.around do |example|
      strategy = example.metadata[:truncate] ? :truncation : :transaction
      all_databases.each do |db|
        DatabaseCleaner[:sequel, db: db].strategy = strategy
        DatabaseCleaner[:sequel, db: db].start
      end
      example.run
      all_databases.each { |db| DatabaseCleaner[:sequel, db: db].clean }
    end

    config.after :each, :truncation do |_example|
      # Not sure why, but some tests need an additional cleaning to actually remove the entries
      all_databases.each do |db|
        DatabaseCleaner[:sequel, db: db].clean_with :truncation, except: ['schema_migrations']
      end
    end
  end
end
