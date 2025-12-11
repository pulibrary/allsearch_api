# frozen_string_literal: true

require 'semantic_logger'
require_relative 'environment'

def new_logger(environment = CURRENT_ENVIRONMENT)
  environment
    .when_development { SemanticLogger.add_appender(io: $stdout, level: :debug) }

  SemanticLogger.add_appender(file_name: "log/#{environment.name}.log")
  SemanticLogger['allsearch-api']
end

ALLSEARCH_LOGGER = new_logger
