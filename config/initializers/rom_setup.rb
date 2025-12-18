# frozen_string_literal: true

require_relative '../../app/paths'
require allsearch_path('init/rom_factory')

# This initializer is responsible for making a ROM container available
# to the application

Rails.application.config.rom = nil

result = RomFactory.new.rom_if_available
result.bind do |container|
  Rails.application.config.rom = container
end
