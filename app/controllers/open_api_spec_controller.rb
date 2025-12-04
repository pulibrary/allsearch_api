# frozen_string_literal: true

require_relative '../paths'

# This module is responsible for serving computer-readable API documentation as YAML
module OpenApiSpecController
  def self.call(_env)
    [
      200,
      {},
      File.readlines(allsearch_path('swagger/v1/swagger.yaml'))
    ]
  end
end
