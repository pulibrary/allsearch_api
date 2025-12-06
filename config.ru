# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'app/paths'
require_relative 'config/environment'
require allsearch_path 'config/allsearch_configs'

run Rails.application
Rails.application.load_server
