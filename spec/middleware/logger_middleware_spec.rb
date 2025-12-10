# frozen_string_literal: true

require 'spec_helper'

describe LoggerMiddleware do
  it 'logs an error' do
    logger = instance_double(SemanticLogger::Logger, error: true)
    app = ->(_env) { raise 'This application hit a weird error!' }
    middleware = described_class.new(app, logger)
    expect { middleware.call({}) }.to raise_error 'This application hit a weird error!'
    expect(logger).to have_received(:error).with(/This application hit a weird error!/)
  end

  it 'logs the response code' do
    logger = instance_double(SemanticLogger::Logger, info: true)
    app = ->(_env) { [418, {}, ['{"tea": "oolong"}']] }
    middleware = described_class.new(app, logger)
    middleware.call({})
    expect(logger).to have_received(:info).with 'Response', hash_including(code: 418)
  end

  it 'logs the number of allocations for the request' do
    logger = instance_double(SemanticLogger::Logger, info: true)
    response = [500, {}, ['cats']]
    app = ->(_env) { response.dup }
    middleware = described_class.new(app, logger)
    middleware.call({})
    a_small_number_of_allocations = satisfy { |data| data[:allocations] < 4 }
    expect(logger).to have_received(:info).with 'Response', a_small_number_of_allocations
  end

  it 'logs the method of the request' do
    logger = instance_double(SemanticLogger::Logger, info: true)
    app = ->(_env) { [500, {}, ['cats']] }
    middleware = described_class.new(app, logger)
    middleware.call({ 'REQUEST_METHOD' => 'GET' })
    expect(logger).to have_received(:info).with 'Response', hash_including(method: 'GET')
  end

  it 'logs the original client ip if available' do
    logger = instance_double(SemanticLogger::Logger, info: true)
    app = ->(_env) { [500, {}, ['cats']] }
    middleware = described_class.new(app, logger)
    middleware.call({ 'HTTP_X_FORWARDED_FOR' => '5.6.7.8', 'HTTP_CLIENT_IP' => '1.2.3.4' })
    expect(logger).to have_received(:info).with 'Response', hash_including(ip: '5.6.7.8')
  end
end
