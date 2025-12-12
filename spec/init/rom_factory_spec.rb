# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/rom_factory'

RSpec.describe RomFactory do
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
      allow(Sequel).to receive(:postgres).and_raise Sequel::Error
      expect { described_class.new.require_rom! }.to raise_exception(/Could not connect to the database/)
    end
  end

  describe 'rom_if_available' do
    it 'returns failure if we cannot verify the activerecord connection' do
      allow(ActiveRecord::Base.connection).to receive(:verify!).and_raise ActiveRecord::NoDatabaseError
      expect(described_class.new.rom_if_available).to be_failure
    end

    it 'returns failure if checking migrations fails' do
      allow(ActiveRecord::Migration).to receive(:check_all_pending!).and_raise ActiveRecord::NoDatabaseError
      expect(described_class.new.rom_if_available).to be_failure
    end

    it 'returns failure if the schema migration table does not exist' do
      allow(ActiveRecord::SchemaMigration).to receive(:new).and_return instance_double(ActiveRecord::SchemaMigration,
                                                                                       table_exists?: false)
      expect(described_class.new.rom_if_available).to be_failure
    end
  end
end
