# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'base64'
gem 'bootsnap', require: false
gem 'csv'
gem 'datadog', '~> 2.28'
gem 'dogstatsd-ruby'
gem 'dry-monads'
gem 'flipper-sequel', require: false
gem 'honeybadger', require: false
gem 'pg'
gem 'rack'
gem 'rack-cors'
gem 'rack-utf8_sanitizer'
gem 'rake'
gem 'rom-sql'
gem 'sanitize', require: false
gem 'semantic_logger', require: false
gem 'summon'
gem 'thor'
gem 'whenever', require: false
gem 'zeitwerk'

group :development do
  gem 'bcrypt_pbkdf'
  gem 'benchmark-ips'
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'ed25519'
  gem 'irb'
  gem 'net-scp'
  gem 'net-ssh'
  gem 'puma'
end

group :development, :test do
  gem 'byebug'
  gem 'listen', require: false
  gem 'reek'
  gem 'rspec_junit_formatter', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'database_cleaner-sequel', require: false
  gem 'rack-test', require: false
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'webmock'
end
