# frozen_string_literal: true

set :repo_url, 'https://github.com/pulibrary/allsearch_api.git'
set :application, 'allsearch_api'

set :branch, ENV['BRANCH'] || 'main'

set :deploy_to, -> { "/opt/#{fetch(:application)}" }

set :log_level, :debug

set :ssh_options, { forward_agent: true }

set :linked_dirs, %w[log]
