# frozen_string_literal: true

set :stage, :staging
set :rails_env, 'staging'
set :linked_dirs, %w[log]

server 'allsearch-api-staging1', user: 'deploy'
