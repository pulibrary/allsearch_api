# frozen_string_literal: true

# Fundamental things, should be started as early as possible in the initialization
require_relative '../app/paths'
require allsearch_path 'init/environment'
require allsearch_path 'init/logger'
require allsearch_path 'config/lando_env'

# Standard init code that does not need to be at the start or end
require allsearch_path 'init/datadog'
require allsearch_path 'init/honeybadger'
require allsearch_path 'init/load_flipper'
require allsearch_path 'init/rom_factory'

# These should be started near the end of the init process
require allsearch_path 'init/yjit'
