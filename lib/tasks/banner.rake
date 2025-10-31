# frozen_string_literal: true

namespace :banner do
  desc 'Update banner [text,alert_status[info|success|warning|error],dismissible,autoclear]'
  task :update, [:text, :alert_status, :dismissible, :autoclear] => :environment do |_task, args|
    banner_repo = BannerRepository.new Rails.application.config.rom
    banner_repo.modify args.to_h
    Rake::Task['banner:show'].invoke
  end

  desc 'Show current banner configuration'
  task show: :environment do
    banner_repo = BannerRepository.new Rails.application.config.rom
    banner = banner_repo.banners.first
    if banner
      puts "The currently set banner text is: #{banner.text}\n"
      puts "The currently set banner alert_status is: #{banner.status_code}\n"
      puts "The currently set banner is dismissible: #{banner.dismissible}\n"
      puts "The currently set banner is autoclear: #{banner.autoclear}"
    else
      puts 'No banner is configured, please run bundle exec rake banner:update'
    end
  end
end
