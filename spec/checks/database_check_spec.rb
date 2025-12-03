# frozen_string_literal: true

require 'rails_helper'

class StubGateway
  def initialize(connection)
    @connection = connection
  end
  attr_reader :connection
end

class StubConnection
  def initialize(test_behavior)
    @test_behavior = test_behavior
  end
  attr_reader :test_behavior

  def test_connection
    test_behavior.call
  end
end

RSpec.describe DatabaseCheck do
  it 'returns success when the connection has a successful test' do
    gateways = [
      StubGateway.new(StubConnection.new(-> { true }))
    ]
    result = described_class.new(gateways).call
    expect(result).to be_success
  end

  it 'returns failure when the connection test returns false' do
    gateways = [
      StubGateway.new(StubConnection.new(-> { false }))
    ]
    result = described_class.new(gateways).call
    expect(result).to be_failure
  end

  it 'returns failure when the connection test raises an error' do
    gateways = [
      StubGateway.new(StubConnection.new(-> { raise SequelError }))
    ]
    result = described_class.new(gateways).call
    expect(result).to be_failure
  end

  it 'returns failure when there are no gateways/active connections' do
    result = described_class.new([]).call
    expect(result).to be_failure
  end
end
