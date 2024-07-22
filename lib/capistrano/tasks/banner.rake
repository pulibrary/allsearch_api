# frozen_string_literal: true

require 'flipper'

namespace :banner do
  desc 'Enable banner'
  task :enable do
    on roles(:db) do
      within '/opt/allsearch_api/current' do
        execute :bundle, :exec, :flipper, :enable, :banner
      end
    end
    run_locally { puts('The banner is now enabled and should display.') }
  end

  desc 'Disable banner'
  task :disable do
    on roles(:db) do
      within '/opt/allsearch_api/current' do
        execute :bundle, :exec, :flipper, :disable, :banner
      end
    end
    run_locally { puts('The banner is now disabled and should not display.') }
  end
end
