# frozen_string_literal: true

class HTTPConfig
  def initialize(http_client: Net::HTTP)
    @http_client = http_client
  end

  def call
    http_client.default_configuration = {
      open_timeout: 1,
      read_timeout: 3.5,
      write_timeout: 3.5
    }
  end

  private

  attr_reader :http_client
end

HTTPConfig.new.call
