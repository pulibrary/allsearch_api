# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Dir.glob('lib/tasks/**/*.rake').each { |file| load file }

ENV['SWAGGER_DRY_RUN'] = 'false' unless ENV.key?('SWAGGER_DRY_RUN')
