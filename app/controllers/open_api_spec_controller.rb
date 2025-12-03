# frozen_string_literal: true

# This module is responsible for serving computer-readable API documentation as YAML
module OpenApiSpecController
  def self.call(_env)
    [
      200,
      {},
      File.readlines("#{__dir__}/../../swagger/v1/swagger.yaml")
    ]
  end
end
