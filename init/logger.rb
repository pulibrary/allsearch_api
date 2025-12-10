# frozen_string_literal: true

require 'semantic_logger'
require_relative 'environment'

CURRENT_ENVIRONMENT
  .when_development { SemanticLogger.add_appender(io: $stdout, level: :debug) }

SemanticLogger.add_appender(file_name: "log/#{CURRENT_ENVIRONMENT.name}.log")

ALLSEARCH_LOGGER = SemanticLogger['allsearch-api']
