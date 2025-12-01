# frozen_string_literal: true

require 'rom'
require 'rom-sql'
require 'dry-monads'
require_relative '../app/relations/banner_relation'

# This class is responsible for creating a Rom::Container
class RomContainer
  include Dry::Monads[:maybe]

  def call
    return None() unless ready?

    db_connection = Sequel.postgres(extensions: :activerecord_connection)
    rom_config = ROM::Configuration.new(:sql, db_connection)
    rom_config.register_relation BannerRelation
    Some(ROM.container(rom_config))
  end

  private

  def ready?
    # We may not even have basic tables like ar_internal_metadata or schema_migrations yet.  In that case,
    # we are definitely not ready!
    return false unless activerecord_tables_exist?

    # Don't attempt to create a ROM container if activerecord hasn't
    # run all migrations, or we might get an error from ROM/Sequel
    # that our tables don't exist
    ActiveRecord::Migration.check_all_pending!
    true
  rescue ActiveRecord::PendingMigrationError, ActiveRecord::DatabaseConnectionError, ActiveRecord::NoDatabaseError,
         ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad
    false
  end

  def activerecord_tables_exist?
    return false unless can_connect_to_db?

    pool = ActiveRecord::Tasks::DatabaseTasks.migration_connection_pool
    required_activerecord_tables = [ActiveRecord::InternalMetadata, ActiveRecord::SchemaMigration].map do |c|
      c.new(pool)
    end
    required_activerecord_tables.all? &:table_exists?
  end

  def can_connect_to_db?
    ActiveRecord::Base.connection.verify!
  rescue ActiveRecord::DatabaseConnectionError
    false
  end
end
