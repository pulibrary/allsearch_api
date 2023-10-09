# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'actionpack'
gem 'actionview'
gem 'activemodel'
gem 'activerecord'
gem 'activesupport'
gem 'bootsnap', require: false
gem 'ddtrace', require: 'ddtrace/auto_instrument'
gem 'dogstatsd-ruby'
gem 'honeybadger'
gem 'lograge'
gem 'logstash-event'
gem 'pg'
gem 'pg_search'
gem 'rack-cors'
gem 'railties'
gem 'rswag'
gem 'summon'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'whenever', require: false

group :development do
  gem 'bcrypt_pbkdf'
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-rails', require: false
  gem 'ed25519'
  gem 'puma', '~> 5.0'
end

group :development, :test do
  gem 'brakeman'
  gem 'pry-byebug'
  gem 'reek'
  gem 'rspec_junit_formatter', require: false
  gem 'rspec-rails'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec'
end

group :test do
  gem 'webmock'
end
