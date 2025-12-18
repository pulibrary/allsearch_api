# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/logger'

# rubocop:disable RSpec/DescribeClass, RSpec/MultipleDescribes
describe '#new_logger' do
  it 'logs to stdout in development' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'APP_ENV' => 'development' }))
    expect(SemanticLogger.appenders.any? { it.instance_of?(SemanticLogger::Appender::IO) }).to be true
  end

  it 'logs to a file in development' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'APP_ENV' => 'development' }))
    expect(SemanticLogger.appenders.any? { it.instance_of?(SemanticLogger::Appender::File) }).to be true
  end

  it 'does not log to IO in production' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'APP_ENV' => 'production' }))
    expect(SemanticLogger.appenders.any? { it.instance_of?(SemanticLogger::Appender::IO) }).to be false
  end

  it 'logs to a file in production' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'APP_ENV' => 'production' }))
    expect(SemanticLogger.appenders.any? { it.instance_of?(SemanticLogger::Appender::File) }).to be true
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
