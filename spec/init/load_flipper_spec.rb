# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/load_flipper'

RSpec.describe LoadFlipper do
  def flipper_loaded?
    $LOADED_FEATURES.any? { it.include? 'flipper-sequel' }
  end

  def create_fake_rom_factory(database_if_available)
    fake = Class.new
    fake.define_method(:database_if_available) { database_if_available }
    fake
  end

  around do |example|
    $LOADED_FEATURES.reject! { it.include? 'flipper-sequel' }
    example.run
    $LOADED_FEATURES.reject! { it.include? 'flipper-sequel' }
  end

  it 'loads flipper if there is a db connection' do
    expect(flipper_loaded?).to be false
    described_class.new(rom_factory_class: create_fake_rom_factory(Success())).call
    expect(flipper_loaded?).to be true
  end

  it 'does not load flipper if there is no db connection' do
    expect(flipper_loaded?).to be false
    described_class.new(rom_factory_class: create_fake_rom_factory(Failure())).call
    expect(flipper_loaded?).to be false
  end
end
