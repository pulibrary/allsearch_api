# frozen_string_literal: true

namespace :servers do
  desc 'Start development servers'
  task :initialize do
    require 'sequel'
    db_server_config = ALLSEARCH_CONFIGS[:database].except(:database)
    Sequel.connect(db_server_config) do |db|
      # Drop active connections to the relevant database
      db.run 'SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity ' \
             "WHERE pg_stat_activity.datname = '#{ALLSEARCH_CONFIGS[:database][:database]}' AND pid <> pg_backend_pid()"
      db.run "DROP DATABASE IF EXISTS #{ALLSEARCH_CONFIGS[:database][:database]}"
      db.run "CREATE DATABASE #{ALLSEARCH_CONFIGS[:database][:database]}"
    end

    Rake::Task['db:migrate'].invoke
  end

  desc 'Start the Apache Solr and PostgreSQL container services using Lando.'
  task :start do
    Rake::Task['solr:update_configs'].invoke
    system('lando start')
    system('bundle exec rake servers:initialize')
    system('APP_ENV=test bundle exec rake servers:initialize')
    system('bundle exec rake solr:load_sample_data')
    system('bundle exec rake best_bets:sync')
  end
end
