# frozen_string_literal: true

require 'spec_helper'
require_relative 'support/database_cleaner'
require allsearch_path 'init/environment'

CURRENT_ENVIRONMENT.when_production do
  abort('The application environment is running in production mode!')
end
RSpec.configure do |config|
  config.include RackTestHelpers
end
