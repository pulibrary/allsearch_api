# frozen_string_literal: true

set :repo_url, 'https://github.com/pulibrary/allsearch_rails_api.git'
set :application, 'allsearch_rails_api'

set :branch, ENV['BRANCH'] || 'main'

set :deploy_to, -> { "/opt/#{fetch(:application)}" }
set :repo_path, -> { "/opt/#{fetch(:application)}/repo" }

set :log_level, :debug

set :ssh_options, { forward_agent: true }

set :passenger_restart_with_touch, true
