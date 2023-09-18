# frozen_string_literal: true

set :stage, :production
set :rails_env, 'production'
set :linked_dirs, %w[log]

server 'allsearch-api-prod1', user: 'deploy'
server 'allsearch-api-prod2', user: 'deploy'
