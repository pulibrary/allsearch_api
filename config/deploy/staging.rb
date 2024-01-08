# frozen_string_literal: true

set :stage, :staging
set :rails_env, 'staging'

server 'allsearch-api-staging1', user: 'deploy', roles: [:app, :db]
server 'allsearch-api-staging2', user: 'deploy', roles: [:app]
