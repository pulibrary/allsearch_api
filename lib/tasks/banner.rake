# frozen_string_literal: true

namespace :banner do
  desc 'Update banner [text,alert_status[info|success|warning|error],dismissible,autoclear]'
  task :update, [:text, :alert_status, :dismissible, :autoclear] => :environment do |_task, args|
    banner = if Banner.count.zero?
               Banner.new
             else
               Banner.first
             end
    banner.rake_update(args)
    Rake::Task['banner:show'].invoke
  end

  desc 'Show current banner configuration'
  task show: :environment do
    banner = Banner.first
    puts "The currently set banner text is: #{banner.text}\n"
    puts "The currently set banner alert_status is: #{banner.alert_status}\n"
    puts "The currently set banner is dismissible: #{banner.dismissible}\n"
    puts "The currently set banner is autoclear: #{banner.autoclear}"
  end
end
