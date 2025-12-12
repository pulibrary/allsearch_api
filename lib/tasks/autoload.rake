# frozen_string_literal: true

require_relative '../../app/paths'
task :autoload do
  require allsearch_path 'init/autoloader'
end
