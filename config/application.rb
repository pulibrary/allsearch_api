# frozen_string_literal: true

require_relative 'boot'

require_relative 'lando_env'
require_relative 'db_connection'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*CURRENT_ENVIRONMENT.bundler_groups)
