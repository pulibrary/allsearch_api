# frozen_string_literal: true

require_relative '../app/paths'

# Load the Rails application.
require_relative 'application'

require allsearch_path 'init/autoloader'

# NOTE: The flipper cli looks for a configuration file config/environment.rb
# for any initializers, so we should not remove the following line unless we
# use an alternate way of working with flipper
require allsearch_path 'init/load_flipper'
