# frozen_string_literal: true

require_relative '../../app/paths'
task :database_connection do
  require allsearch_path 'init/rom_factory'
  ALLSEARCH_ROM = RomFactory.new.require_rom!
end
