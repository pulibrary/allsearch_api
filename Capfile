# frozen_string_literal: true

# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'
require 'capistrano/passenger'
require 'capistrano/rails'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

require 'capistrano/honeybadger'

require 'whenever/capistrano'

# Needed for capistrano rake tasks
require 'flipper'
