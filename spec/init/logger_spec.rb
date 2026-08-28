# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/logger'

# rubocop:disable RSpec/DescribeClass, RSpec/MultipleDescribes
describe '#new_logger' do
  it 'logs to stdout in development' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'APP_ENV' => 'development' }))
    expect(SemanticLogger.appenders.any?(SemanticLogger::Appender::IO)).to be true
  end

  it 'logs to a file in development' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'APP_ENV' => 'development' }))
    expect(SemanticLogger.appenders.any?(SemanticLogger::Appender::File)).to be true
  end

  it 'does not log to IO in production' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'APP_ENV' => 'production' }))
    expect(SemanticLogger.appenders.any?(SemanticLogger::Appender::IO)).to be false
  end

  it 'logs to a file in production' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'APP_ENV' => 'production' }))
    expect(SemanticLogger.appenders.any?(SemanticLogger::Appender::File)).to be true
    expect(SemanticLogger.appenders.first.file_name).to eq 'log/production.log'
  end

  def line_count(file_path) = File.read(file_path).scan("\n").count

  it 'does not log INFO messages in production' do
    SemanticLogger.clear_appenders!
    Tempfile.create do |file|
      logger = new_logger(Environment.new({ 'APP_ENV' => 'production' }), file.path)
      expect { logger.info('Hi', { nice_data: 'great!' }) }.not_to(change { line_count(file.path) })
    end
  end

  it 'logs WARN messages in production' do
    SemanticLogger.clear_appenders!
    Tempfile.create do |file|
      logger = new_logger(Environment.new({ 'APP_ENV' => 'production' }), file.path)

      expect do
        logger.warn('Oh no', { worry_level: 'medium' })
      end.to change { line_count(file.path) }.by 1
    end
  end
end

class FakePassenger
  def self.on_event(_event_name)
    yield true
  end
end

describe '#configure_passenger_for_logger' do
  it 'reopens the logger after passenger forks the process' do
    allow(SemanticLogger).to receive :reopen
    stub_const('PhusionPassenger', FakePassenger)
    configure_passenger_for_logger
    expect(SemanticLogger).to have_received :reopen
  end
end
# rubocop:enable RSpec/DescribeClass, RSpec/MultipleDescribes
