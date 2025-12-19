# frozen_string_literal: true

require_relative 'boot'

require 'active_record'

require_relative 'lando_env'
require_relative 'db_connection'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*CURRENT_ENVIRONMENT.bundler_groups)

# Use the sql format so that we can capture our postgres custom search configuration
ActiveRecord.schema_format = :sql
