# frozen_string_literal: true

require_relative '../../app/paths'

desc 'Interactive console to investigate the classes and functionality of this application'
task :console do
  require allsearch_path 'init/autoloader'
  require allsearch_path 'init/rom'
  require 'irb'

  ALLSEARCH_ROM = require_rom!
  ARGV.clear
  IRB.start
end

desc 'Shortcut for rake console'
task c: :console
