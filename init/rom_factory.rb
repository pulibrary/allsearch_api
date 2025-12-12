# frozen_string_literal: true

require 'rom'
require 'rom-sql'
require 'dry-monads'
require_relative 'environment'
require_relative '../config/db_connection'
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
    db_connection
      .bind { |connection| verify_db_connection_is_ready(connection) }
      .bind { |_connection| verify_required_rom_tables }
      .bind { |connection| rom_container(connection) }
  end

  private

  def db_connection
    return Success(DB) if defined?(DB) && DB

    db_config = ALLSEARCH_CONFIGS[:database]
    Success(Sequel.postgres(db_config[:database], user: db_config[:username], password: db_config[:password],
                                                  host: db_config[:host], port: db_config[:port]))
  rescue StandardError => error
    Failure(error)
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

  # rubocop:disable Metrics/MethodLength
  def verify_required_rom_tables
    conn = db_connection.value!

    # Check for sequel_schema_migrations table (created by ROM)
    unless conn.table_exists?(:sequel_schema_migrations)
      return Failure(StandardError.new(
                       'ROM migration tracking table does not exist. Run: bundle exec rake rom:migrate'
                     ))
    end

    # Check for required tables that ROM relations depend on
    required_tables = [:best_bet_records, :oauth_tokens, :library_databases, :library_staff_documents, :banners]
    missing_tables = required_tables.reject { |table| conn.table_exists?(table) }

    if missing_tables.empty?
      Success()
    else
      Failure(StandardError.new(
                "Required tables missing: #{missing_tables.join(', ')}. Run: bundle exec rake rom:migrate"
              ))
    end
  rescue StandardError => error
    Failure(error)
  end
  # rubocop:enable Metrics/MethodLength

  def verify_db_connection_is_ready(connection)
    Success(connection)
  rescue StandardError => error
    Failure(error)
  end
end
