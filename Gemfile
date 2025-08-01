# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'actionpack'
gem 'activemodel'
gem 'activerecord'
gem 'activesupport'
gem 'bootsnap', require: false
gem 'csv'
gem 'datadog', '~> 2.0', require: 'datadog/auto_instrument'
gem 'dogstatsd-ruby'
gem 'flipper-active_record'
gem 'health-monitor-rails'
gem 'honeybadger'
gem 'logstash-event'
gem 'pg'
gem 'rack-cors'
gem 'rack-utf8_sanitizer'
gem 'rails_semantic_logger'
gem 'railties', '~> 8.0'
gem 'rswag'
gem 'summon'
gem 'tzinfo-data', '~> 1.2025'
gem 'whenever', require: false

group :development do
  gem 'bcrypt_pbkdf'
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'ed25519'
  gem 'puma'
end

group :development, :test do
  gem 'brakeman'
  gem 'pry-byebug'
  gem 'reek'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :test do
  gem 'simplecov', require: false
  gem 'webmock'
end
