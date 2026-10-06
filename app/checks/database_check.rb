# frozen_string_literal: true

require 'dry-monads'

class DatabaseCheck
  include Dry::Monads[:result]

  def initialize(gateway)
    @gateway = gateway
  end

  def call
    case can_connect_to_active_connection?
    when nil
      Failure('No active database connections')
    when true
      Success()
    else
      Failure('Problem connecting with database')
    end
  rescue StandardError => error
    Failure(error.message)
  end

  private

  attr_reader :gateway

  def can_connect_to_active_connection?
    gateway&.connection.test_connection
  end
end
