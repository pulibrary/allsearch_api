# frozen_string_literal: true

require 'spec_helper'
require allsearch_path 'init/logger'

# rubocop:disable RSpec/DescribeClass
describe '#new_logger' do
  it 'logs to stdout in development' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'RAILS_ENV' => 'development' }))
    expect(SemanticLogger.appenders.any? { it.instance_of?(SemanticLogger::Appender::IO) }).to be true
  end

  it 'logs to a file in development' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'RAILS_ENV' => 'development' }))
    expect(SemanticLogger.appenders.any? { it.instance_of?(SemanticLogger::Appender::File) }).to be true
  end

  it 'does not log to IO in production' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'RAILS_ENV' => 'production' }))
    expect(SemanticLogger.appenders.any? { it.instance_of?(SemanticLogger::Appender::IO) }).to be false
  end

  it 'logs to a file in production' do
    SemanticLogger.clear_appenders!
    new_logger(Environment.new({ 'RAILS_ENV' => 'production' }))
    expect(SemanticLogger.appenders.any? { it.instance_of?(SemanticLogger::Appender::File) }).to be true
  end
end
# rubocop:enable RSpec/DescribeClass
