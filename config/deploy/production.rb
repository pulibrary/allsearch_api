# frozen_string_literal: true

set :stage, :production
set :app_env, 'production'

server 'allsearch-api-prod1.princeton.edu', user: 'deploy', roles: [:app, :db, :prod_db]
server 'allsearch-api-prod2.princeton.edu', user: 'deploy', roles: [:app]
