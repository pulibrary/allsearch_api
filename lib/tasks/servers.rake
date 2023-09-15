# frozen_string_literal: true

namespace :servers do
  desc 'Start development servers'
  task initialize: :environment do
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end

  desc 'Start the Apache Solr and PostgreSQL container services using Lando.'
  task start: :environment do
    Rake::Task['solr:update_configs'].invoke
    system('lando start')
    system('rake servers:initialize')
    system('rake servers:initialize RAILS_ENV=test')
  end
end
