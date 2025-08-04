# frozen_string_literal: true

require_relative '../rom_container'
require Rails.root.join('lib/middleware/rom')

# This initializer is responsible for making a ROM container available
# to the application
RomContainer.new.call.bind do |container|
  # Make the container available to Rack applications and middleware
  #
  # Eventually, it would be nice to move this to config.ru, so that it
  # does not rely on Rails infrastructure.  However, the request specs
  # seem to not pick up on middlewares defined in config.ru, so we would
  # have to refactor those first.
  Rails.application.config.middleware.use RomMiddleware, container

  # Make the container available to the Rails application
  Rails.application.config.rom = container
end
