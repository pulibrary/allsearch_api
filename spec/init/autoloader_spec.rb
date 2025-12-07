# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/autoloader'

class FakeFileListener
  def initialize(_path_generator = ->(path) { allsearch_path(path) })
    @listening = false
  end

  def call
    @listening = true
  end

  def listening?
    @listening
  end
end

def with_fake_directory
  Dir.mktmpdir do |directory|
    Dir.mkdir("#{directory}/app")
    Dir.mkdir("#{directory}/app/checks")
    yield directory
  end
end

RSpec.describe Autoloader do
  it 'eagerly loads constants in production' do
    with_fake_directory do |directory|
      listener = FakeFileListener.new
      environment = Environment.new({ 'RAILS_ENV' => 'production' })
      path_generator = ->(path) { "#{directory}/#{path}" }
      autoloader = described_class.new(directories: ['app/checks'], environment:, listener:, path_generator:)

      file_name = path_generator.call('app/checks/eagerly_loaded_check.rb')
      File.open(file_name, 'w') do |file|
        file.puts 'class EagerlyLoadedCheck; end'
      end

      expect(defined?(EagerlyLoadedCheck)).to be_falsey
      expect($LOADED_FEATURES).not_to include file_name

      autoloader.call

      expect(defined?(EagerlyLoadedCheck)).to be_truthy
      expect($LOADED_FEATURES).to include file_name
    end
  end

  it 'lazily loads constants in development' do
    with_fake_directory do |directory|
      listener = FakeFileListener.new
      environment = Environment.new({ 'RAILS_ENV' => 'development' })
      path_generator = ->(path) { "#{directory}/#{path}" }
      autoloader = described_class.new(directories: ['app/checks'], environment:, listener:, path_generator:)

      file_name = path_generator.call('app/checks/lazily_loaded_check.rb')
      File.open(file_name, 'w') do |file|
        file.puts 'class LazilyLoadedCheck; end'
      end

      expect(defined?(LazilyLoadedCheck)).to be_falsey
      expect($LOADED_FEATURES).not_to include file_name

      autoloader.call

      # It still has not loaded our file, since our code has not yet used LazilyLoadedCheck
      expect($LOADED_FEATURES).not_to include file_name

      # Now, we finally use LazilyLoadedCheck and it is loaded
      LazilyLoadedCheck.new
      expect(defined?(LazilyLoadedCheck)).to be_truthy
      expect($LOADED_FEATURES).to include file_name
    end
  end

  describe 'file listening' do
    it 'sets up a file listener in development' do
      with_fake_directory do |directory|
        listener = FakeFileListener.new
        environment = Environment.new({ 'RAILS_ENV' => 'development' })
        path_generator = ->(path) { "#{directory}/#{path}" }
        autoloader = described_class.new(directories: ['app/checks'], environment:, listener:, path_generator:)
        autoloader.call
        expect(listener.listening?).to be true
      end
    end

    it 'does not set up a file listener in production' do
      with_fake_directory do |directory|
        listener = FakeFileListener.new
        environment = Environment.new({ 'RAILS_ENV' => 'production' })
        path_generator = ->(path) { "#{directory}/#{path}" }
        autoloader = described_class.new(directories: ['app/checks'], environment:, listener:, path_generator:)
        autoloader.call
        expect(listener.listening?).to be false
      end
    end
  end
end
