# frozen_string_literal: true

class DatabaseCheck
  include Dry::Monads[:result]

  def initialize(gateways)
    @gateways = gateways
  end

  def call
    if no_active_connections?
      Failure('No active database connections')
    elsif can_connect_to_all_active_connections?
      Success()
    else
      Failure('Problem connecting with database')
    end
  rescue StandardError => error
    Failure(error.message)
  end

  private

  attr_reader :gateways

  def no_active_connections?
    gateways.empty?
  end

  def can_connect_to_all_active_connections?
    gateways.all? { |gateway| gateway.connection.test_connection }
  end
end
