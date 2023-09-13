# frozen_string_literal: true

namespace :servers do
  desc 'Start development servers'
  task start: :environment do
    Rake::Task['db:create'].invoke
    Rake::Task['solr:update_configs'].invoke
    `lando start`
  end
end
