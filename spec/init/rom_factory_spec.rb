# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/rom_factory'

RSpec.describe RomFactory do
  describe '#db_connection' do
    it 'returns success with existing DB constant if already defined' do
      result = described_class.new.send(:db_connection)
      expect(result).to be_success
      expect(result.success).to be_a(Sequel::Database)
    end

    context 'when DB constant is not defined' do
      before do
        hide_const('DB')
      end

      it 'returns success with database connection when connection succeeds' do
        db = instance_double(Sequel::Postgres::Database, to_s: 'postgres://my-connection-string')
        allow(Sequel).to receive(:postgres).and_return(db)
        result = described_class.new.send(:db_connection)
        expect(result).to be_success
        expect(result.success).to eq(db)
      end

      it 'returns failure when database connection fails' do
        allow(Sequel).to receive(:postgres).and_raise(Sequel::DatabaseConnectionError.new('Connection failed'))
        result = described_class.new.send(:db_connection)
        expect(result).to be_failure
        expect(result.failure).to be_a(Sequel::DatabaseConnectionError)
      end
    end
  end

  describe '#require_rom!' do
    # rubocop: disable RSpec/VerifiedDoubles
    it 'returns a rom if the database connection is good' do
      db = instance_double(Sequel::Postgres::Database, to_s: 'postgres://my-connection-string')
      allow(Sequel).to receive(:postgres).and_return(db)
      rom_config = double('ROM::Configuration', register_relation: true,
                                                default: instance_double(ROM::Gateway, use_logger: true)).as_null_object
      allow(ROM::Configuration).to receive(:new).and_return(rom_config)
      allow(ROM).to receive(:container).and_return(ROM::Container.new([], [], [], []))
      expect(described_class.new.require_rom!).to be_instance_of ROM::Container
    end
    # rubocop: enable RSpec/VerifiedDoubles

    it 'raises an error if the database connection is bad' do
      rom_factory = described_class.new
      allow(rom_factory).to receive(:db_connection).and_return(Failure(Sequel::Error.new))
      expect { rom_factory.require_rom! }.to raise_exception(/Could not connect to the database/)
    end
  end

  describe 'rom_if_available' do
    it 'returns failure if we cannot connect to the database' do
      rom_factory = described_class.new
      allow(rom_factory).to receive(:db_connection).and_return(Failure(Sequel::DatabaseConnectionError.new))
      expect(rom_factory.rom_if_available).to be_failure
    end

    it 'returns failure if required tables do not exist' do
      db = instance_double(Sequel::Postgres::Database, to_s: 'postgres://my-connection-string')
      allow(db).to receive(:table_exists?).with(:sequel_schema_migrations).and_return(false)
      rom_factory = described_class.new
      allow(rom_factory).to receive(:db_connection).and_return(Success(db))
      expect(rom_factory.rom_if_available).to be_failure
    end

    it 'returns success when database is ready and ROM can be initialized' do
      db = instance_double(Sequel::Postgres::Database, to_s: 'postgres://my-connection-string')
      allow(Sequel).to receive(:postgres).and_return(db)
      allow(db).to receive(:table_exists?).with(:schema_migrations).and_return(true)
      allow(db).to receive(:table_exists?).with(:ar_internal_metadata).and_return(true)
      # rubocop :disable RSpec/VerifiedDoubles
      rom_config = double('ROM::Configuration', register_relation: true,
                                                default: instance_double(ROM::Gateway, use_logger: true)).as_null_object
      # rubocop :enable RSpec/VerifiedDoubles
      allow(ROM::Configuration).to receive(:new).and_return(rom_config)
      allow(ROM).to receive(:container).and_return(ROM::Container.new([], [], [], []))
      expect(described_class.new.rom_if_available).to be_success
    end
  end
end
