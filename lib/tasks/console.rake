# frozen_string_literal: true

require_relative '../../app/paths'

desc 'Interactive console to investigate the classes and functionality of this application'
task console: [:autoload, :database_connection] do
  require 'irb'
  ARGV.clear
  IRB.start
end

desc 'Shortcut for rake console'
task c: :console
