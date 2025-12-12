# frozen_string_literal: true

require 'rom'
require 'rom-sql'
require 'dry-monads'
require_relative 'environment'
require allsearch_path 'init/logger'
require allsearch_path 'app/relations/banner_relation'
require allsearch_path 'app/relations/best_bet_relation'
require allsearch_path 'app/relations/library_database_relation'
require allsearch_path 'app/relations/library_staff_relation'
require allsearch_path 'app/relations/oauth_token_relation'

include Dry::Monads[:result]

# Class responsible for setting up a database connection and ROM container.
# All methods should return Success or Failure so they can be
# more easily composed with each other.
class RomFactory
  def require_rom!
    db_connection
      .bind { |connection| rom_container(connection) }
      .value_or { |err| raise "Could not connect to the database: #{err.message}" }
  end

  def database_if_available
    db_connection
  end

  def rom_if_available
    verify_active_record_connection
      .bind { verify_required_tables }
      .bind { verify_database_is_ready }
      .bind { activerecord_db_connection }
      .bind { |connection| rom_container(connection) }
  end

  private

  def db_connection
    db_config = ALLSEARCH_CONFIGS[:database]
    Success(Sequel.postgres(db_config[:database], user: db_config[:username], password: db_config[:password],
                                                  host: db_config[:host], port: db_config[:port]))
  rescue StandardError => error
    Failure(error)
  end

  def activerecord_db_connection
    Success(Sequel.postgres(extensions: :activerecord_connection))
  end

  def rom_container(db_connection)
    rom_config = ROM::Configuration.new(:sql, db_connection)
    rom_config.register_relation BannerRelation
    rom_config.register_relation BestBetRelation
    rom_config.register_relation LibraryDatabaseRelation
    rom_config.register_relation LibraryStaffRelation
    rom_config.register_relation OAuthTokenRelation
    rom_config.default.use_logger ALLSEARCH_LOGGER
    Success(ROM.container(rom_config))
  end

  def verify_active_record_connection
    Success(ActiveRecord::Base.connection.verify!)
  rescue ActiveRecord::DatabaseConnectionError, ActiveRecord::NoDatabaseError => error
    Failure(error)
  end

  # We may not even have basic tables like ar_internal_metadata or schema_migrations yet.
  def verify_required_tables
    pool = ActiveRecord::Tasks::DatabaseTasks.migration_connection_pool
    required_activerecord_tables = [ActiveRecord::InternalMetadata, ActiveRecord::SchemaMigration].map { |table| table.new(pool) }
    if required_activerecord_tables.all? &:table_exists?
      Success()
    else
      Failure(StandardError.new(
                'The basic tables of this database do not yet exist, please run migrations or load the db structure'
              ))
    end
  end

  def verify_database_is_ready
    # Don't attempt to create a ROM container if activerecord hasn't
    # run all migrations, or we might get an error from ROM/Sequel
    # that our tables don't exist
    ActiveRecord::Migration.check_all_pending!
    Success()
  rescue ActiveRecord::PendingMigrationError, ActiveRecord::DatabaseConnectionError, ActiveRecord::NoDatabaseError,
         ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad => error
    Failure(error)
  end
end
