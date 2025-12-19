# frozen_string_literal: true

set :repo_url, 'https://github.com/pulibrary/allsearch_api.git'
set :application, 'allsearch_api'

set :branch, ENV['BRANCH'] || 'main'

set :deploy_to, -> { "/opt/#{fetch(:application)}" }

set :log_level, :debug

set :ssh_options, { forward_agent: true }

set :linked_dirs, %w[log]

# Run migrations after code update
after 'deploy:updated', 'deploy:migrate'

namespace :application do
  # You can/ should apply this command to a single host
  # cap --hosts=allsearch-api-staging1.princeton.edu staging application:remove_from_nginx
  desc 'Marks the server(s) to be removed from the loadbalancer'
  task :remove_from_nginx do
    count = 0
    on roles(:app) do
      count += 1
    end
    if count > (roles(:app).length / 2)
      raise 'You must run this command on no more than half the servers utilizing the --hosts= switch'
    end

    on roles(:app) do
      within release_path do
        execute :touch, 'public/remove-from-nginx'
      end
    end
  end

  # You can/ should apply this command to a single host
  # cap --hosts=allsearch-api-staging1.princeton.edu staging application:serve_from_nginx
  desc 'Marks the server(s) to be added back to the loadbalancer'
  task :serve_from_nginx do
    on roles(:app) do
      within release_path do
        execute :rm, '-f public/remove-from-nginx'
      end
    end
  end
end

namespace :database do
  # Runs database migrations
  desc 'Run database migrations'
  task :db_migrate do
    on roles(:db) do
      within release_path do
        execute :rake, 'db:migrate_to_rom'
      end
    end
  end
end

namespace :deploy do
  task :after_release do
    invoke! "database:db_migrate"
  end
end
