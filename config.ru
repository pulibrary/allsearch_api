# frozen_string_literal: true

# This file is used by Rack-based servers to start the application.

require_relative 'app/paths'

require allsearch_path 'init/environment'

require_relative 'config/environment'
require allsearch_path 'config/allsearch_configs'
require allsearch_path 'app/router'

run Rails.application.config.middleware.build(Router)
Rails.application.load_server
