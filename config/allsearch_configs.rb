# frozen_string_literal: true

require_relative '../app/paths'
require allsearch_path 'app/environment'
require 'forwardable'

environment = Environment.new

# Access a config with ALLSEARCH_CONFIGS[:allsearch][:summon]
ALLSEARCH_CONFIGS = {
  allsearch: environment.config(:allsearch),
  database: environment.config(:database)
}.freeze
