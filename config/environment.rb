# frozen_string_literal: true

require_relative '../app/paths'

# Load the Rails application.
require_relative 'application'

require allsearch_path 'init/autoloader'
require allsearch_path 'config/initialize_rails'

InitializeRails.new.call
