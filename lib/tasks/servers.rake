# frozen_string_literal: true

namespace :servers do
  desc 'Start development servers'
  task initialize: :environment do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end

  desc 'Start the Apache Solr and PostgreSQL container services using Lando.'
  task start: :environment do
    Rake::Task['solr:update_configs'].invoke
    system('lando start')
    system('bundle exec rake servers:initialize')
    system('RAILS_ENV=test bundle exec rake db:migrate')
    system('bundle exec rake solr:load_sample_data')
    system('bundle exec rake best_bets:sync')
  end
end
