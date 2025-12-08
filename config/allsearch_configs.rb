# frozen_string_literal: true

require_relative '../app/paths'
require allsearch_path 'init/environment'
require 'forwardable'

# Access a config with ALLSEARCH_CONFIGS[:allsearch][:summon]
ALLSEARCH_CONFIGS = {
  allsearch: CURRENT_ENVIRONMENT.config(:allsearch),
  database: CURRENT_ENVIRONMENT.config(:database)
}.freeze
