# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every :hour, roles: [:prod_db] do
  rake 'best_bets:sync'
end

every :hour, roles: [:prod_db] do
  rake 'library_databases:sync'
end

# Run  at 5:00 am EST or 6:00 am EDT
every 1.day, at: '10:00 am' do
  rake 'library_staff:sync'
end
