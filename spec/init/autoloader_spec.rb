# frozen_string_literal: true

require 'listen'

require 'spec_helper'
require allsearch_path 'init/autoloader'

class FakeFileListener
  def initialize(_path_generator = ->(path) { allsearch_path(path) })
    @listening = false
    @on_file_change = -> {}
  end

  def call(&block)
    @listening = true
    @on_file_change = -> { block.call }
  end

  def listening?
    @listening
  end

  def simulate_file_change
    @on_file_change.call
  end
end

def with_temp_directory
  Dir.mktmpdir do |directory|
    Dir.mkdir("#{directory}/app")
    Dir.mkdir("#{directory}/app/checks")
    yield directory
  end
end

RSpec.describe Autoloader do
  it 'eagerly loads constants in production' do
    with_temp_directory do |directory|
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
    with_temp_directory do |directory|
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

  it 'finds new constants when the File Listener detects a change in development' do
    with_temp_directory do |directory|
      environment = Environment.new({ 'RAILS_ENV' => 'development' })
      listener = FakeFileListener.new
      path_generator = ->(path) { "#{directory}/#{path}" }
      autoloader = described_class.new(directories: ['app'], environment:, listener:, path_generator:)

      File.open(path_generator.call('app/my_gastropod.rb'), 'w') do |file|
        file.puts 'MyGastropod = :slug'
      end

      autoloader.call

      expect(MyGastropod).to eq :slug
      expect(defined?(MyCephalopod)).to be_falsey

      File.open(path_generator.call('app/my_cephalopod.rb'), 'w') do |file|
        file.puts 'MyCephalopod = :squid'
      end
      listener.simulate_file_change

      expect(MyCephalopod).to eq :squid
    end
  end

  describe 'file listening' do
    it 'sets up a file listener in development' do
      with_temp_directory do |directory|
        listener = FakeFileListener.new
        environment = Environment.new({ 'RAILS_ENV' => 'development' })
        path_generator = ->(path) { "#{directory}/#{path}" }
        autoloader = described_class.new(directories: ['app/checks'], environment:, listener:, path_generator:)
        autoloader.call
        expect(listener.listening?).to be true
      end
    end

    it 'does not set up a file listener in production' do
      with_temp_directory do |directory|
        listener = FakeFileListener.new
        environment = Environment.new({ 'RAILS_ENV' => 'production' })
        path_generator = ->(path) { "#{directory}/#{path}" }
        autoloader = described_class.new(directories: ['app/checks'], environment:, listener:, path_generator:)
        autoloader.call
        expect(listener.listening?).to be false
      end
    end

    describe 'default file listener' do
      it 'listens to the app directory' do
        with_temp_directory do |directory|
          mock_listen_listener = instance_double(Listen::Listener)
          allow(mock_listen_listener).to receive(:start)
          allow(Listen).to receive(:to).and_return(mock_listen_listener)
          path_generator = ->(path) { "#{directory}/#{path}" }

          FileListener.new(path_generator:).call { 'my nice logic' }

          expect(Listen).to have_received(:to).with("#{directory}/app")
        end
      end

      it 'accepts the callback we provide through FileListener#call' do
        with_temp_directory do |directory|
          mock_listen_listener = instance_double(Listen::Listener)
          allow(mock_listen_listener).to receive(:start)
          allow(Listen).to receive(:to)
            .and_return(mock_listen_listener)
            .and_yield(['filename1'], ['filename2'], [])
          path_generator = ->(path) { "#{directory}/#{path}" }

          callback_was_accepted = false

          FileListener.new(path_generator:).call { callback_was_accepted = true }

          expect(callback_was_accepted).to be true
        end
      end
    end
  end
end
